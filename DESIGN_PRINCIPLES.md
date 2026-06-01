1. Keep templates modular
Do not put everything in one giant .typ file. Split layout logic into reusable blocks.

2. Prefer Quarto conventions
Let users write ordinary Quarto documents. typstR should extend, not replace, Quarto.

3. Make metadata declarative
Users should provide metadata once, and the package should map it into the template cleanly.

4. Provide sensible defaults
The package should look polished out of the box.

5. Minimize magic
Avoid hidden behavior that makes debugging hard.
