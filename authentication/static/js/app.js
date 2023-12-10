document.onmouseover = function(e) {
    var target = e.target;
    target.style.transition = "transform 1s";
    target.style.transform = "rotate(360deg)";
}
