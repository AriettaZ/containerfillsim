### Installing ContainerFill Sim

Before installing this app, you need to be an AweSim developer in the `awsmdev` group and have already accessed https://apps.awesim.org/devapps/ at least once. For more info see https://github.com/AweSim-OSC/AweSim/wiki

1. ssh into `glenn.osc.edu`
2. cd into the `awesim_dev` directory
3. Clone https://github.com/AweSim-OSC/containerfillsim into an available app dir (rails1, rails2, ...)
4. `module load` the correct ruby version (currently `module load ruby-2.0.0-p247`)
5. cd into the new rails directory and run `bundle install --local` and `rake db:schema:load`

You should now be able to access the app through devapps catalog: https://apps.awesim.org/devapps/
