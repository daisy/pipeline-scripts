
var braillePages,textPages;
var brailleButton,textButton;
function init() {
    braillePages = Array.prototype.slice.call(document.getElementsByClassName('braille-page'),0);
    textPages = Array.prototype.slice.call(document.getElementsByClassName('text-page'),0);
    brailleButton = document.getElementById('view-braille');
    textButton = document.getElementById('view-text');
}
function show(elem,index,array) {
    elem.style.display='block';
}
function hide(elem,index,array) {
    elem.style.display='none';
}
function toggleView(elem) {
    brailleButton.className = brailleButton.className.replace('active', '');
    textButton.className = textButton.className.replace('active', '');
    elem.className += ' active';
    if (elem.id == 'view-braille') {
        braillePages.forEach(show);
        textPages.forEach(hide);
    } else {
        braillePages.forEach(hide);
        textPages.forEach(show);
    }
};
window.onload = init;
