// borrowed from pandoc
// https://github.com/jgm/pandoc/blob/1433aaa4c35af84fbe00ecf971acd1414da6dea8/src/Text/Pandoc/Writers/HTML.hs#L283
document.addEventListener("DOMContentLoaded", function () {
    var mathElements = document.getElementsByClassName("math");
    for (var i = 0; i < mathElements.length; i++) {
        var texText = mathElements[i].firstChild;
        if (mathElements[i].tagName == "SPAN") {
            katex.render(texText.data, mathElements[i],
                         {displayMode: mathElements[i].classList.contains("display"),
                          throwOnError: false });
        }
    }
});
