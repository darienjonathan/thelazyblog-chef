namespace :db do
  %w[create drop migrate seed].each do |command|
    desc "rake db:#{command}"
    task command do
      on roles(:app) do
        within "#{current_path}" do
          with rails_env: "#{fetch(:stage)}" do
            execute :rake, "db:#{command}"
          end
        end
      end
    end
  end
end

namespace :assets do
  %w[precompile clean].each do |command|
    desc "rake assets:#{command}"
    task command do
      on roles(:app) do
        within "#{current_path}" do
          with rails_env: "#{fetch(:stage)}" do
            execute :rake, "assets:#{command}"
          end
        end
      end
    end
  end
end