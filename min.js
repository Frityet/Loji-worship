const fs = require('fs');
const path = require('path');
const { minify } = require('html-minifier-terser');

// Simple argument parser
const args = {};
process.argv.slice(2).forEach((arg, i, arr) => {
  if (arg.startsWith('--')) {
    const key = arg.slice(2);
    const val = arr[i + 1];
    if (val && !val.startsWith('--')) {
      args[key] = val;
    } else {
      args[key] = true;
    }
  }
});

// Required arguments
const htmlPath = args.html;
const cssPath = args.css;
const jsPath = args.js;
const outputPath = args.out || 'index.min.html';

if (!htmlPath || !cssPath || !jsPath) {
  console.error(`Usage:
  node build.js --html index.html --css styles.css --js script.js [--out index.min.html]`);
  process.exit(1);
}

try {
  const htmlContent = fs.readFileSync(htmlPath, 'utf-8');
  const cssContent = fs.readFileSync(cssPath, 'utf-8');
  const jsContent = fs.readFileSync(jsPath, 'utf-8');

  // Replace <link href="..."> with inlined <style>
  let combinedHtml = htmlContent.replace(
    new RegExp(`<link[^>]+href=["']${path.basename(cssPath)}["'][^>]*>`, 'i'),
    `<style>${cssContent}</style>`
  );

  // Replace <script src="..."> with inlined <script>
  combinedHtml = combinedHtml.replace(
    new RegExp(`<script[^>]+src=["']${path.basename(jsPath)}["'][^>]*>\\s*</script>`, 'i'),
    `<script>${jsContent}</script>`
  );

  const minifyOptions = {
    collapseWhitespace: true,
    removeComments: true,
    removeRedundantAttributes: true,
    minifyCSS: true,
    minifyJS: true
  };

  (async () => {
    try {
      const minifiedHtml = await minify(combinedHtml, minifyOptions);
      fs.writeFileSync(outputPath, minifiedHtml, 'utf-8');
      console.log(`✅ Minified HTML created at: ${outputPath}`);
    } catch (err) {
      console.error('❌ Minification failed:', err);
    }
  })();

} catch (err) {
  console.error('❌ Error reading files:', err);
}
