# frozen_string_literal: true
require 'sidekiq/api'

namespace :app do
  desc 'remove private data'
  task remove_private_data: :environment do
    if Rails.env.development?
      User.delete_all
      AuthToken.delete_all
      ApiKey.delete_all
      Repository.where(private: true).find_each do |repo|
        begin
          repo.destroy
        rescue Elasticsearch::Transport::Transport::Errors::NotFound
          nil
        end
      end
      Subscription.delete_all
      WebHook.delete_all
    end
  end

  desc 'set the internal flag for an api key to true'
  task :set_internal_api_key, [:token] => :environment do |_task, args|
    key = ApiKey.find_by(access_token: args[:token])
    if key.nil?
      puts "Unable to find API key with token #{args[:token]}"
    else
      key.update_attribute(:is_internal, true)
      puts "Updated internal flag for #{key.access_token}"
    end
  end

  desc 'clear sidekiq queues and schedules workers'
  task :clear_sidekiq do 
    Sidekiq::Queue.all.each(&:clear)
    Sidekiq::RetrySet.new.clear
    Sidekiq::ScheduledSet.new.clear
    Sidekiq::DeadSet.new.clear
  end
end
