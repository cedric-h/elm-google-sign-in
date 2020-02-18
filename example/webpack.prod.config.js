const path = require('path');
const HtmlWebpackPlugin = require('html-webpack-plugin');
const webpack = require('webpack');

module.exports = {
    entry: './index.js',
    output: {
        path: path.resolve(__dirname, 'dist'),
        filename: 'index.js',
    },
	module: {
		rules: [
			{
				test: /\.css$/,
				use: ["style-loader", "css-loader"]
			},
			{
				test: /\.elm$/,
				exclude: [/elm-stuff/, /node_modules/],
				use: {
					loader: 'elm-webpack-loader',
					options: {
						optimize: true,
						runtimeOptions: ['-A128M', '-H128M', '-n8m'],
						files: [
							path.resolve(__dirname, "src/Main.elm"),
						]
					}
				}
			}
		]
	},
	plugins: [ new HtmlWebpackPlugin({ template: 'index.html', title: "elm-google-sign-in Example" }) ],
	mode: 'production'
};
