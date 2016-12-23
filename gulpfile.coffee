
_ = require 'lodash/fp'
path = require 'path'
gulp = require 'gulp'
request = require 'request'
url = require 'url'

$ = _.merge do require('gulp-load-plugins'), {
    del: (option, glob) -> require('del')(glob, option)
    rollup: require('rollup').rollup
    closure: require('google-closure-compiler-js').gulp()
    exec: require('child_process').exec
    watch: (task, glob) -> gulp.watch glob, debounceDelay: 1000, task
}



val = {
    npm: 'node_modules'
    source: 'source'
    dist: 'dist'
    dev: 'dev'
    tmp: '.tmp'
}



utils = {
    list: _.flow [
        _.trim
        _.split /\s+|,/
    ]

    path:
        src: (str = '') -> path.join val.source, str
        dst: (str = '') -> path.join val.dist, str
        tmp: (str = '') -> path.join val.tmp, str
        dev: (str = '') -> path.join val.dev, str
        npm: (str = '') -> path.join val.npm, str

    require: _.memoize (module, config = {}) ->
        if _.isString config then config = require config
        require(module)(config)

    prod: !!$.util.env.production
}









gulp.task 'clean', ->

    $.del {force: true}, [
        utils.path.dst()
        utils.path.tmp()
        utils.path.src 'codegen'
    ]









gulp.task 'assets', ->

    gulp.src [
            utils.path.src 'assets/*'
        ]

        .pipe $.if (({path}) -> not utils.prod and path.endsWith 'assets/index.html'),
            $.replace /(<script)\s+async/, '$1'

        .pipe $.if (({path}) -> utils.prod and path.endsWith 'assets/index.html'),
            $.replace /(<link rel="icon" href=")(.*)(">)/, '$1favicon.ico$3'

        .pipe $.if (({path}) -> utils.prod and path.endsWith 'assets/index.html'),
            $.replace /(src="scripts\/bundle)(.js)/, '$1.min$2'

        .pipe gulp.dest utils.path.dst()









gulp.task 'polyfills', ->

    vendor = '
        core-js/client/shim.min.js

        intl/dist/Intl.min.js
        intl/locale-data/jsonp/en.js

        zone.js/dist/zone.min.js
    '

    vendor_dev = '
        zone.js/dist/long-stack-trace-zone.min.js
    '

    make = _.flow _.compact [
        (vendor, dev) ->
            return vendor if utils.prod
            return vendor.concat '\n', dev

        utils.list

        _.filter _.negate _.startsWith '-'

        not utils.prod and _.map (item) ->
            item.replace '.min.js', '.js'

        _.map utils.path.npm
    ]

    gulp.src make vendor, vendor_dev
        .pipe $.if utils.prod, $.uglify mangle: false
        .pipe $.concat 'polyfills.min.js'
        .pipe gulp.dest utils.path.dst 'scripts'









gulp.task 'css.vendor', ->

    vendor = '
        purecss/build/pure-min.css
        purecss/build/grids-responsive-min.css
        purecss/build/buttons-min.css
        purecss/build/tables-min.css

        github-fork-ribbon-css/gh-fork-ribbon.css
    '

    make = _.flow _.compact [
        utils.list

        _.filter _.negate _.startsWith '-'

        not utils.prod and _.map (item) ->
            item.replace /[-.]min.css/, '.css'

        _.map utils.path.npm
    ]

    gulp.src make vendor
        .pipe $.concat 'vendor.min.css'
        .pipe $.stripComments.text space: false
        .pipe gulp.dest utils.path.dst 'styles'









gulp.task 'rollup', ['scripts'], (callback) ->

    $.rollup {
        entry: utils.path.dst(
            if utils.prod then 'scripts/main.aot.js' else 'scripts/main.js'
        )
        context: 'window'
        cache: utils.cache
        plugins: _.compact [

            utils.require 'rollup-plugin-node-resolve', {
                jsnext: true
                browser: true
            }

            utils.require 'rollup-plugin-commonjs', {
                sourceMap: false
            }

            utils.require 'rollup-plugin-inject', do ->
                config = exclude: 'node_modules/**', modules: {}

                map_w_key = _.mapValues.convert 'cap': false
                make = map_w_key (value, key) -> ['tslib', key]

                modules = make require 'tslib'

                return _.assign config, {modules}
        ]
    }

    .then (bundle) ->

        utils.cache = bundle

        bundle.write {
            format: 'iife'
            dest: utils.path.dst 'scripts/bundle.js'
        }









gulp.task 'rollup.post', ['rollup'], ->

    gulp.src utils.path.dst 'scripts/bundle.js'

        .pipe $.stripComments space: false

        .pipe $.if utils.prod,
            $.closure {
                outputWrapper: '(function(){\n%output%\n}).call(this)'
                assumeFunctionWrapper: true
                rewritePolyfills: false
                warningLevel: 'QUIET'
                jsOutputFile: 'bundle.min.js'
            }

        .pipe gulp.dest utils.path.dst 'scripts'

        .on 'end', ->

            uri = url.format {
                protocol: 'http:'
                port: (require './'.concat utils.path.dev 'bs-config').port
                hostname: 'localhost'
                pathname: '__browser_sync__'
                search: '?method=reload'
            }

            request(uri)
                .on 'response', _.noop
                .on 'error', _.noop









gulp.task 'tmp', ['tmp.inlineNg2']


gulp.task 'tmp.src', ->

    gulp.src [
            utils.path.src '**'
            utils.path.src '!**/assets/**'
            utils.path.src '!**/*.css'
        ]
        .pipe gulp.dest utils.path.tmp(), dot: true


gulp.task 'tmp.tsconfig', ['tmp.src'], ->

    gulp.src utils.path.tmp 'tsconfig.json'
        .pipe $.if utils.prod,
            $.replace /(strictNullChecks.:(\s+)?)true/, '$1false'
        .pipe gulp.dest utils.path.tmp(), dot: true


gulp.task 'tmp.css', ['tmp.tsconfig'],  ->

    gulp.src [
            utils.path.src '**/*.css'
            utils.path.tmp '!**/*.less'
        ]
        .pipe $.postcss [
            utils.require 'postcss-simple-vars', {
                variables: require './'.concat utils.path.src 'styles/variables'
            }
            utils.require 'postcss-selector-not'
            utils.require 'postcss-nesting'
            utils.require 'postcss-color-function'
            utils.require 'autoprefixer'
        ]
        .pipe gulp.dest utils.path.tmp(), dot: true
        .pipe gulp.dest utils.path.dst()


gulp.task 'tmp.inlineNg2', ['tmp.css'], ->

    gulp.src utils.path.tmp '**'
        .pipe $.if not utils.prod,
            $.inlineNg2Template {
                base: 'source'
                useRelativePaths: true
            }
        .pipe gulp.dest utils.path.tmp(), dot: true









gulp.task 'typescript', ['tmp'], (callback) ->

    if utils.prod

        $.exec "cd #{ utils.path.tmp() } ; ../node_modules/.bin/ngc",

            (err, stdout, stderr) ->
                $.debug stdout
                $.debug stderr
                callback err

    else

        ts = $.typescript.createProject utils.path.tmp('tsconfig.json'), {
            typescript: require 'typescript'
            isolatedModules: true
        }

        gulp.src [
                utils.path.tmp '**/*.{ts,tsx,d.ts}'
                '!**/main.aot.ts'
            ]
            .pipe $.plumber()
            .pipe ts()
            .pipe gulp.dest utils.path.dst()









gulp.task 'scripts', ['typescript'], ->

    gulp.src [
            utils.path.src '**'
            '!**/*.ts'
            '!**/*.css'
            '!**/*.html'
        ]

        # .pipe $.debug minimal: true

        .pipe $.plumber()

        .pipe $.if '**/*.{coffee,coffee.md,litecoffee}',
            $.coffee bare: true

        .pipe gulp.dest utils.path.dst()









gulp.task 'rollup.post.report', ['rollup.post'], ->

    list = utils.list '
        scripts/polyfills.min.js
        scripts/bundle.min.js
        styles/vendor.min.css
        styles/main.css
        index.html
    '

    gulp.src list.map utils.path.dst
        .pipe $.sizereport {
            gzip: true
        }









gulp.task 'dev', utils.list('assets css.vendor polyfills rollup.post'), ->

    return if $.util.env.build

    $.watch utils.list('rollup.post'), [
       utils.path.src 'app/**/*.{css,html}'
       utils.path.src '**/*.{js,coffee,coffee.md,litecoffee,ts,tsx}'
    ]

    $.watch utils.list('tmp'), [
       utils.path.src 'styles/**/*.{css,coffee}'
    ]









gulp.task 'build', utils.list 'assets css.vendor polyfills rollup.post.report'









gulp.task 'bundle.shared', ['scripts'], ->

    $.rollup {
        entry: utils.path.dst 'app/@shared/**/index.js'
        context: 'window'
        plugins: [
            utils.require 'rollup-plugin-multi-entry'
        ]
    }

    .then (bundle) ->

        bundle.write {
            format: 'cjs'
            intro: 'var window = {};'
            moduleName: 'shared'
            dest: utils.path.dst 'app/@shared/index.js'
        }









gulp.task 'test', ['bundle.shared'], ->

    gulp.src 'test/spec/**/*.spec.{coffee,coffee.md,litcoffee,js}'
        .pipe $.jasmine()









gulp.task 'default', ['dev']
