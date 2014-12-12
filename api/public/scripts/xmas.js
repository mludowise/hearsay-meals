var utils = {
    randomNumber: function (n) {
       var number =  Math.floor(Math.random() * n) + 1
       return number;
    }
}

var xmas = {};
xmas.imagesBaseUrl = './images/xmas/';
xmas.imageName = 'spikey-plant.png';
xmas.imageTag = '<img src="' + xmas.imagesBaseUrl + xmas.imageName + '" class="xmas-image">';
xmas.appendImage = function (url) {
    $('.navbar-header').prepend(xmas.imageTag);
    console.log(utils.randomNumber(23));
};
xmas.init = function () {
    xmas.appendImage();
}

$(document).ready(xmas.init);