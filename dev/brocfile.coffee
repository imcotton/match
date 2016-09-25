
_ = require 'lodash/fp'

broccoli = {
    env: require('broccoli-env').getEnv()

    funnel: require 'broccoli-funnel'
    merges: require 'broccoli-merge-trees'
    concat: require 'broccoli-concat'

    rollup: require './broccoli-rollup'

    coffee: require 'broccoli-coffee'
    typify: require 'broccoli-typescript-compiler'

    uglify: require 'broccoli-uglify-sourcemap'
}



utils = {
    list: _.flow [
        _.trim
        _.split /\s+|,/
    ]

    list_by_suffix: (raw) ->
        @list(raw).map (suffix) ->
            "**/*.#{ suffix }"

    partial: _.rest (fn, rest) -> _.partial fn, rest

    task: _.flow [
        _.compact
        _.flow
        _.attempt
    ]

    prod: {
        _check: -> broccoli.env is 'production'

        _default: (func, condition) ->
            if _.attempt(condition) then func else null

        on: (func) -> @_default func, @_check
        off: (func) -> @_default func, _.negate @_check
    }

    require: (module, config = {}) ->
        if _.isString config then config = require config
        require(module)(config)

    npm_resolve: (rest...) ->
        require('path').resolve [__dirname, '../node_modules', rest...]...

    get_funnel_tree: _.flow [
        _.omitBy (val, key) -> _.startsWith '_', key
        _.values
        _.compact
    ]
}



collection = utils.get_funnel_tree {

    source: utils.task [ #-----------------------------------------------------
        utils.partial broccoli.funnel, 'source', {
            exclude: utils.list_by_suffix '
                coffee
                coffee.md
                litcoffee
                less
                sass
                ts
            '
        }
    ]

    polyfills: utils.task [ #--------------------------------------------------

        utils.partial broccoli.funnel, 'node_modules', {
            destDir: 'scripts/polyfills'
            files: utils.list '
                core-js/client/shim.min.js
                zone.js/dist/zone.min.js
            '
            back: utils.list '
                reflect-metadata/Reflect.js
            '
        }

        utils.prod.on utils.partial broccoli.uglify, _, {
            mangle: false
            sourceMapConfig: enabled: false
        }

        utils.partial broccoli.concat, _, {
            outputFile: 'scripts/polyfills.min.js'
            inputFiles: '**/*'
            header: ';(function() {'
            footer: '}());'
            sourceMapConfig: enabled: false
        }
    ]

    coffee: utils.task [ #-----------------------------------------------------

        utils.partial broccoli.funnel, 'source', {
            include: utils.list_by_suffix '
                coffee
                coffee.md
                litcoffee
            '
        }

        utils.partial broccoli.coffee, _, {
            bare: false
        }
    ]

    typescript: utils.task [ #-------------------------------------------------

        utils.partial broccoli.funnel, 'source', {
            include: utils.list_by_suffix '
                coffee
                coffee.md
                litcoffee
                ts
                js
            '
            exclude: utils.list_by_suffix '
                d.ts
            '
        }

        utils.partial broccoli.typify, _, {
            tsconfig: 'source/tsconfig.json'
        }

        utils.partial broccoli.rollup, _, {
            inputFiles: '**/*'
            rollup: {
                entry: 'scripts/main.js'
                dest: 'scripts/bundle.js'
                format: 'iife'
                plugins: _.compact [
                    resolveId: (id, from) ->
                        rxjs = 'rxjs'
                        if id.startsWith rxjs
                            return utils.npm_resolve id.replace ///(#{ rxjs })(.*)///, '$1-es$2.js'

                        if id.startsWith '@angular'
                            return utils.npm_resolve id, 'esm/index.js'

                    utils.require 'rollup-plugin-node-resolve'

                    null && utils.require 'rollup-plugin-babel', {
                        exclude: 'node_modules/@angular/*'
                        presets: [
                            require 'babel-preset-es2015-rollup'
                        ]
                    }

                    null && utils.require 'rollup-plugin-buble', {
                        transforms: {
                            modules: false
                            dangerousForOf: true
                            spreadRest: true
                        }
                    }
                ]
            }
        }

        utils.partial broccoli.typify, _, {
            tsconfig: 'source/tsconfig.es5.json'
        }

        null && utils.prod.on utils.partial broccoli.uglify, _, {
            mangle: false
            sourceMapConfig: enabled: false
        }

        utils.partial broccoli.concat, _, {
            outputFile: 'scripts/bundle.min.js'
            inputFiles: '**/*'
            sourceMapConfig: enabled: false
        }
    ]

    index_root: utils.task [ #-------------------------------------------------
        utils.partial broccoli.funnel, 'source/assets', {
            include: utils.list '
                *.*
            '
        }
    ]
}









module.exports = broccoli.merges collection, overwrite: true
