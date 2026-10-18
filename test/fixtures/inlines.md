Code spans: `zat --ansi`, `` a ` inside ``, and `` ` `` alone.

Escapes \*stay\* literal, entities decode: &copy; &#169; &#xA9; &nope;

Autolinks <https://github.com/amalrik/zat> and <dev@example.com>,
inline HTML <kbd>Ctrl</kbd>+<kbd>C</kbd>.

A hard break with spaces  
and with a backslash\
then a soft one
here.

Emphasis: *italic*, **bold**, ***both***, ~~struck~~, and *nested **bold** back to italic*.
Leftovers stay literal: snake_case_name, 2 * 3 * 4, ***a**.

Links: [the repo](https://github.com/amalrik/zat "Zat"), [*styled* text](/docs), and ![a logo](logo.png).
Not links: [no destination], [a] (spaced), \[escaped](x).
