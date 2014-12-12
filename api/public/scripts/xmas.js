var utils = {
    randomNumber: function (n) {
        var number = Math.floor(Math.random() * n) + 1;
        return number;
    }
}

var xmas = {};
xmas.imagesBaseUrl = './images/xmas/';
xmas.imageNames = ['','spikey-plant.png','reindeer.png', 'bells.png', 'bird.png'];
xmas.imageTag = '<img src="' + xmas.imagesBaseUrl + xmas.imageNames[utils.randomNumber(4)] + '" class="xmas-image">';
xmas.appendImage = function (url) {
    $('.navbar-header').prepend(xmas.imageTag);
    console.log(utils.randomNumber(1));
};
xmas.init = function () {
    xmas.appendImage();
}

$(document).ready(xmas.init);