#!/usr/bin/env python3
"""
Build optimized SQLite database from CSV for Kaloree app.

This script converts the Indian Food Nutrition CSV into a prebuilt SQLite 
database with FTS5 full-text search for fast queries.

Usage: python build_food_db.py

Output: assets/data/indian_foods.db
"""

import sqlite3
import csv
import os
import sys

# Paths relative to script location
SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
PROJECT_ROOT = os.path.dirname(SCRIPT_DIR)
CSV_PATH = os.path.join(PROJECT_ROOT, 'assets/data/Indian_Food_Nutrition_Processed.csv')
DB_PATH = os.path.join(PROJECT_ROOT, 'assets/data/indian_foods.db')


def categorize_food(name):
    """Auto-categorize food based on keywords."""
    name_lower = name.lower()
    
    categories = {
        'Breakfast': ['idli', 'dosa', 'upma', 'poha', 'paratha', 'uttapam', 'pongal'],
        'Rice': ['rice', 'biryani', 'pulao', 'khichdi'],
        'Bread': ['roti', 'naan', 'chapati', 'bread', 'puri', 'bhatura'],
        'Snack': ['samosa', 'pakora', 'vada', 'bhaji', 'kachori', 'tikki'],
        'Dessert': ['sweet', 'halwa', 'kheer', 'gulab', 'ladoo', 'barfi', 'jalebi', 'rasgulla'],
        'Beverage': ['tea', 'chai', 'coffee', 'lassi', 'juice', 'sharbat', 'buttermilk', 'espresso'],
        'Side Dish': ['raita', 'chutney', 'pickle', 'papad', 'salad', 'dal', 'sambar'],
    }
    
    for category, keywords in categories.items():
        for keyword in keywords:
            if keyword in name_lower:
                return category
    
    return 'Main Course'


def clean_name(name):
    """Clean and normalize food name."""
    if not name:
        return ''
    
    # Remove extra whitespace
    name = ' '.join(name.split())
    
    # Capitalize first letter of each word
    words = name.split()
    cleaned_words = []
    for word in words:
        if word:
            # Handle parentheses
            if word.startswith('('):
                cleaned_words.append('(' + word[1:].capitalize())
            else:
                cleaned_words.append(word.capitalize())
    
    return ' '.join(cleaned_words)


def parse_float(value, default=0.0):
    """Safely parse float value."""
    if not value:
        return default
    try:
        return float(value.replace(',', ''))
    except (ValueError, AttributeError):
        return default


def build_database():
    """Build the optimized SQLite database from CSV."""
    print("🔧 Building optimized SQLite database...")
    print(f"   Source: {CSV_PATH}")
    print(f"   Output: {DB_PATH}")
    
    # Check if CSV exists
    if not os.path.exists(CSV_PATH):
        print(f"❌ CSV file not found: {CSV_PATH}")
        sys.exit(1)
    
    # Remove existing database
    if os.path.exists(DB_PATH):
        os.remove(DB_PATH)
        print("   Removed existing database")
    
    conn = sqlite3.connect(DB_PATH)
    cursor = conn.cursor()
    
    # Apply static DB optimizations for minimal footprint
    cursor.execute("PRAGMA journal_mode=OFF;")
    cursor.execute("PRAGMA synchronous=OFF;")
    cursor.execute("PRAGMA temp_store=MEMORY;")
    cursor.execute("PRAGMA page_size=4096;")
    cursor.execute("PRAGMA encoding='UTF-8';")
    
    print("   Applied optimization pragmas")
    
    # Create main table (matches Drift schema)
    cursor.execute('''
        CREATE TABLE indian_foods (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL,
            aliases TEXT,
            category TEXT NOT NULL,
            region TEXT NOT NULL DEFAULT 'All India',
            serving_size TEXT NOT NULL DEFAULT '100g',
            serving_grams INTEGER NOT NULL DEFAULT 100,
            calories INTEGER NOT NULL,
            protein REAL NOT NULL,
            carbs REAL NOT NULL,
            fat REAL NOT NULL,
            fiber REAL NOT NULL DEFAULT 0
        )
    ''')
    
    print("   Created main table")
    
    # Create FTS5 virtual table for fast full-text search
    cursor.execute('''
        CREATE VIRTUAL TABLE indian_foods_fts USING fts5(
            name,
            aliases,
            content='indian_foods',
            content_rowid='id',
            tokenize='porter unicode61'
        )
    ''')
    
    print("   Created FTS5 virtual table")
    
    # Import CSV data
    row_count = 0
    skipped = 0
    
    with open(CSV_PATH, 'r', encoding='utf-8') as f:
        reader = csv.DictReader(f)
        
        for row in reader:
            name = clean_name(row.get('Dish Name', ''))
            if not name:
                skipped += 1
                continue
            
            # Parse nutritional values (CSV has decimal format)
            calories = round(parse_float(row.get('Calories (kcal)', 0)))
            carbs = parse_float(row.get('Carbohydrates (g)', 0))
            protein = parse_float(row.get('Protein (g)', 0))
            fat = parse_float(row.get('Fats (g)', 0))
            fiber = parse_float(row.get('Fibre (g)', 0))
            
            # Auto-categorize
            category = categorize_food(name)
            
            cursor.execute('''
                INSERT INTO indian_foods 
                (name, aliases, category, region, serving_size, serving_grams, 
                 calories, protein, carbs, fat, fiber)
                VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
            ''', (name, None, category, 'All India', '100g', 100,
                  calories, protein, carbs, fat, fiber))
            
            row_count += 1
    
    print(f"   Imported {row_count} foods (skipped {skipped})")
    
    # Populate FTS table
    cursor.execute('''
        INSERT INTO indian_foods_fts(rowid, name, aliases)
        SELECT id, name, aliases FROM indian_foods
    ''')
    
    print("   Populated FTS index")
    
    # Optimize FTS
    cursor.execute("INSERT INTO indian_foods_fts(indian_foods_fts) VALUES('optimize')")
    
    # Create index on category for filtering
    cursor.execute("CREATE INDEX idx_category ON indian_foods(category)")
    
    # Analyze for query planner
    cursor.execute("ANALYZE;")
    
    conn.commit()
    
    # Vacuum to minimize size
    cursor.execute("VACUUM;")
    
    conn.commit()
    conn.close()
    
    # Calculate sizes
    csv_size = os.path.getsize(CSV_PATH)
    db_size = os.path.getsize(DB_PATH)
    
    print("\n📊 Build Statistics:")
    print(f"   Rows imported: {row_count}")
    print(f"   CSV size:      {csv_size / 1024:.1f} KB")
    print(f"   DB size:       {db_size / 1024:.1f} KB")
    print(f"   Size change:   {((db_size - csv_size) / csv_size * 100):+.1f}%")
    print(f"\n✅ Database built successfully at:")
    print(f"   {DB_PATH}")


def verify_database():
    """Verify the built database."""
    print("\n🔍 Verifying database...")
    
    conn = sqlite3.connect(DB_PATH)
    cursor = conn.cursor()
    
    # Check row count
    cursor.execute("SELECT COUNT(*) FROM indian_foods")
    count = cursor.fetchone()[0]
    print(f"   Total foods: {count}")
    
    # Check FTS works
    cursor.execute("""
        SELECT name FROM indian_foods_fts 
        WHERE indian_foods_fts MATCH 'chai*' 
        LIMIT 5
    """)
    results = cursor.fetchall()
    print(f"   FTS search 'chai*': {len(results)} results")
    for r in results[:3]:
        print(f"      - {r[0]}")
    
    # Check categories distribution
    cursor.execute("""
        SELECT category, COUNT(*) as cnt 
        FROM indian_foods 
        GROUP BY category 
        ORDER BY cnt DESC
    """)
    print("   Categories:")
    for cat, cnt in cursor.fetchall():
        print(f"      - {cat}: {cnt}")
    
    conn.close()
    print("\n✅ Verification complete")


if __name__ == '__main__':
    build_database()
    verify_database()
