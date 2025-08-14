# Adrian Snaps Photography Portfolio

A Hugo-based photography portfolio using the `hugo-theme-gallery/v4` theme, showcasing photography galleries organized into categories: Art, Cityscapes, Nature, People, and Featured Album.

## Development

```bash
# Install Hugo modules
hugo mod get

# Start development server
npm run dev
# or
hugo server

# Build production site
npm run build
# or
hugo --gc --minify
```

## Gallery Management

### Randomize Gallery Order

To randomize the display order of images in galleries:

```bash
# Randomize a single gallery
./randomize-gallery-weights.sh content/nature/ --yes

# Randomize all galleries at once
for gallery in content/art/ content/cityscapes/ content/nature/ content/people/ content/featured-album/; do ./randomize-gallery-weights.sh "$gallery" --yes; done
```

This script:
- Assigns random weight parameters to each image
- Uses weight-based sorting (`Params.weight`)
- Automatically sets highest-weight image as cover
- Only modifies `index.md` files for minimal git impact
