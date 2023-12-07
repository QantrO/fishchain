// If an element is hovered over, rotate it 360 degrees for 1 second

document.onmouseover = function(e) {
    var target = e.target;
    target.style.transition = "transform 1s";
    target.style.transform = "rotate(360deg)";
}
