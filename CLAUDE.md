# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a Hugo-based photography portfolio website using the `hugo-theme-gallery/v4` theme. The site showcases photography galleries organized into categories: Art, Cityscapes, Nature, People, and Featured Album. Built images are served from the `public/` directory as a static site.

## Development Commands

- **Build production site**: `hugo --gc --minify` or `npm run build`
- **Start development server**: `hugo server` or `npm run dev`
- **Install Hugo modules**: `hugo mod get`

## Project Structure

### Content Organization
- `content/` - All site content and images
  - `_index.md` - Main gallery listing page
  - `about.md` - About page
  - `imprint.md` - Imprint/legal page
  - Gallery folders (`art/`, `cityscapes/`, `nature/`, `people/`, `featured-album/`)
    - Each contains `index.md` with gallery metadata and `.jpg` image files
- `config/_default/hugo.toml` - Main Hugo configuration
- `layouts/partials/head-custom.html` - Custom HTML head content
- `assets/css/custom.css` - Custom CSS overrides
- `public/` - Generated static site (build output)
- `resources/` - Hugo-generated image processing cache

### Configuration Files
- `go.mod` - Hugo module dependencies
- `package.json` - NPM scripts for build/dev
- `hugo.toml` - Site configuration including:
  - Image processing settings (75% quality, CatmullRom resampling)
  - Gallery theme settings
  - Social media links
  - Long timeout (1000s) for image processing

### Gallery System
Each gallery has an `index.md` with frontmatter specifying:
- `title` and `description`
- `weight` for menu ordering
- `featured_image` for gallery covers
- `theme` (light/dark)
- `sort_order` and `sort_by` for image ordering

## Adding New Content

### New Gallery
1. Create folder in `content/` (e.g., `content/portraits/`)
2. Add `index.md` with gallery metadata
3. Add image files (.jpg format)
4. Images are automatically processed into multiple sizes by Hugo

### Adding Images to Existing Gallery
Simply add .jpg files to the gallery folder - Hugo will automatically include them in the gallery display and generate responsive image variants.

### Configuration Changes
- Site settings: Edit `config/_default/hugo.toml`
- Custom styling: Edit `assets/css/custom.css`
- Custom head content: Edit `layouts/partials/head-custom.html`

## Technical Notes

- Uses Hugo modules for theme management
- Image processing generates multiple sizes automatically (handled in `resources/_gen/images/`)
- Site supports RSS feeds and robots.txt
- Built for GitHub Pages deployment
- Theme supports both light and dark modes
- Long build timeout configured due to extensive image processing