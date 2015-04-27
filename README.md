### Installing ContainerFill Sim

Before installing this app, you need to be an AweSim developer in the `awsmdev` group and have already accessed https://apps.awesim.org/devapps/ at least once. For more info see https://github.com/AweSim-OSC/AweSim/wiki

1. ssh into `glenn.osc.edu`
2. cd into the `awesim_dev` directory
3. Clone https://github.com/AweSim-OSC/containerfillsim into an available app dir (rails1, rails2, ...)
4. `module load` the correct ruby version (currently `module load ruby-2.0.0-p247`)
5. cd into the new rails directory and run `bundle install --local` and `rake db:schema:load`
6. cp the `.htaccess.development` to `.htaccess`

You should now be able to access the app through devapps catalog: https://apps.awesim.org/devapps/

### Updating ContainerFill Sim

1. ssh into `glenn.osc.edu`
2. cd into the `awesim_dev/rails1` directory
3. Pull down any updates into the app directory using `git`
4. If there is a database update you will need to run

```
rake db:migrate
```

You should now have an up-to-date copy of the app.

### Modernizr and Old Browser Support

Currently it is recommended to use Modernizr for feature detection. If a feature in the browser is not detected, then you should have a polyfill to fall back on. Modernizr facilitates detecting the feature and calling the polyfill you supply.

Safari doesn't support HTML5 Datalist (big surprise). A slightly modified polyfill is added to

```
lib/assets/javascripts/polyfill
```

In order to add HTML5 Datalist feature detection a production Modernizr was built with the following options at: http://modernizr.com/download/#-input-addtest-elem_datalist-load

* **Input Attributes** under the HTML5 section
* **Modernizr.addTest** under the Extensibility section
* **Modernizr.load** under the Extra section
* **elem-datalist** under the Non-core detects

This `modernizr.js` was placed in

```
vendor/assets/javascripts/
```

If you would like to add a polyfill for a future feature, please don't forget to also include the previous Modernizr options as well or you may break HTML5 Datalist feature detection.
