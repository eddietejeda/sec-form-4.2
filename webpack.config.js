const path = require('path');
const MiniCssExtractPlugin = require('mini-css-extract-plugin')
const Dotenv = require('dotenv-webpack');

module.exports = {
  entry: ['./javascript/app.js', './stylesheets/style.scss'],
  output: {
    path: path.resolve(__dirname, 'public'),
    filename: 'app.js'
  },
  plugins: [
    new Dotenv(),
    new MiniCssExtractPlugin({
        filename: 'style.css'
    })
  ],  
  module: {
    rules: [
      {
        test: /\.s?css$/,
        use: [
          MiniCssExtractPlugin.loader,
          'css-loader',
          'sass-loader'
        ]
      }
    ]
  }
}
