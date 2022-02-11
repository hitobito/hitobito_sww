# encoding: utf-8

namespace :app do
  namespace :license do
    task :config do # rubocop:disable Rails/RakeEnvironment
      @licenser = Licenser.new('hitobito_sww',
                               'TODO: Customer Name',
                               'https://github.com/hitobito/hitobito_sww')
    end
  end
end
