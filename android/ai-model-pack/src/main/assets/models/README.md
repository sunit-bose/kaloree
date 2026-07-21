# AI Model Pack - SmolVLM-256M

This directory contains the SmolVLM-256M model files for on-device food image analysis.

## Model Files Required

Download the following files from HuggingFace and place them in this directory:

| File | Size | Description |
|------|------|-------------|
| `smolvlm-256m-instruct-q8_0.gguf` | ~300 MB | Main VLM model (Q8 quantized) |
| `smolvlm-256m-clip-q8_0.gguf` | ~65 MB | CLIP vision encoder |

**Total size: ~365 MB**

## Download Instructions

### Option 1: Using HuggingFace CLI

```bash
# Install huggingface-cli if not already installed
pip install huggingface_hub

# Download model files
cd android/ai-model-pack/src/main/assets/models/

huggingface-cli download HuggingFaceTB/SmolVLM-256M-Instruct-GGUF \
  smolvlm-256m-instruct-q8_0.gguf \
  smolvlm-256m-clip-q8_0.gguf \
  --local-dir ./
```

### Option 2: Manual Download

1. Go to https://huggingface.co/HuggingFaceTB/SmolVLM-256M-Instruct-GGUF
2. Download the files:
   - `smolvlm-256m-instruct-q8_0.gguf`
   - `smolvlm-256m-clip-q8_0.gguf`
3. Place them in this directory

## Building with PAD

After adding the model files, build the App Bundle:

```bash
flutter build appbundle
```

This will create an AAB file with the model as a separate asset pack.

## Testing PAD Locally

Use bundletool to test the asset pack delivery:

```bash
# Build APKs from the AAB
bundletool build-apks \
  --bundle=build/app/outputs/bundle/release/app-release.aab \
  --output=app.apks \
  --local-testing

# Install on device
bundletool install-apks --apks=app.apks
```

In local testing mode, the asset pack is available immediately.

## Production Deployment

When uploaded to Google Play:
1. The base APK downloads first (~30 MB)
2. The asset pack downloads automatically after install (fast-follow)
3. Users see download progress in the Play Store

## Quantization Options

| Quantization | Model Size | RAM Usage | Quality |
|--------------|------------|-----------|---------|
| Q8_0 | ~300 MB | ~365 MB | Best |
| Q6_K | ~250 MB | ~310 MB | Good |
| Q5_K_M | ~210 MB | ~260 MB | Moderate |
| Q4_K_M | ~170 MB | ~220 MB | Lower |

We use Q8_0 for best accuracy in food recognition.

## Privacy Note

These model files run entirely on-device:
- No internet required for inference
- Food images never leave the device
- No API keys or cloud services needed
