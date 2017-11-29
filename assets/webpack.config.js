const webpack = require('webpack');
const { join, resolve } = require('path');
const merge = require('webpack-merge');
const CopyWebpackPlugin = require('copy-webpack-plugin');
const HTMLWebpackPlugin = require('html-webpack-plugin');
const CleanWebpackPlugin = require('clean-webpack-plugin');

const ENVIRONMENT = process.env.npm_lifecycle_event === 'prod' ? 'production' : 'development';
const paths = {
  src: resolve(__dirname),
  dest: resolve(join(__dirname, '../priv/static/'))
};

let configuration = {
  entry: join(paths.src, 'index.js'),
  output: {
    path: paths.dest,
    filename: 'application.js'
  },
  resolve: {
    extensions: ['.js', '.elm', '.scss', '.png'],
    modules: [
      paths.src,
      "node_modules"
    ]
  },
  module: {
    rules: [
      {
        test: /\.html$/,
        exclude: /node_modules/,
        loader: 'file-loader?name=[name].[ext]'
      }, {
        test: /\.js$/,
        exclude: [
          /node_modules/, /deps/
        ],
        use: {
          loader: 'babel-loader',
          options: {
            // env: automatically determines the Babel plugins you need based on your supported environments
            presets: ['env']
          }
        }
      }, {
        test: /\.scss$/,
        exclude: [
          /elm-stuff/, /node_modules/
        ],
        loaders: ["style-loader", "css-loader", "sass-loader"]
      }, {
        test: /\.css$/,
        exclude: [
          /elm-stuff/, /node_modules/
        ],
        loaders: ["style-loader", "css-loader"]
      }, {
        test: /\.woff(2)?(\?v=[0-9]\.[0-9]\.[0-9])?$/,
        exclude: [
          /elm-stuff/, /node_modules/
        ],
        loader: "url-loader",
        options: {
          limit: 10000,
          mimetype: "application/font-woff"
        }
      }, {
        test: /\.(ttf|eot|svg)(\?v=[0-9]\.[0-9]\.[0-9])?$/,
        exclude: [
          /elm-stuff/, /node_modules/
        ],
        loader: "file-loader"
      }, {
        test: /\.(jpe?g|png|gif|svg)$/i,
        loader: 'file-loader'
      }
    ]
  }
}

if (ENVIRONMENT === 'development') {
  configuration = merge(configuration, {
    plugins: [
      // Suggested for hot-loading
      new webpack.NamedModulesPlugin(),
      // Prevents compilation errors causing the hot loader to lose state
      new webpack.NoEmitOnErrorsPlugin()
    ],
    module: {
      rules: [
        {
          test: /\.elm$/,
          exclude: [
            /elm-stuff/, /node_modules/
          ],
          use: [
            {
              loader: "elm-hot-loader"
            }, {
              loader: "elm-webpack-loader",
              // add Elm's debug overlay to output
              options: {
                debug: true
              }
            }
          ]
        }
      ]
    }
  });
}

if (ENVIRONMENT === 'production') {
  configuration = merge(configuration, {
    plugins: [
      // Delete everything from output directory and report to user
      new CleanWebpackPlugin([], {
        root: __dirname,
        exclude: [],
        verbose: true,
        dry: false
      }),
      new CopyWebpackPlugin([
        {
          from: join(paths.src, 'images')
        }
      ]),
      // TODO update to version that handles =>
      new webpack.optimize.UglifyJsPlugin()
    ],
    module: {
      rules: [
        {
          test: /\.elm$/,
          exclude: [
            /elm-stuff/, /node_modules/
          ],
          use: [
            {
              loader: "elm-webpack-loader"
            }
          ]
        }
      ]
    }
  });
}

module.exports = configuration;
