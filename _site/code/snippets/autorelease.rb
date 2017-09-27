if ENV["TRAVIS_BRANCH"] == "master" && ENV["GEMFURY_PASSWORD"] && ENV["GEMFURY_USERNAME"]
  `echo -e "machine git.fury.io\n  login #{ENV["GEMFURY_USERNAME"]}\n  password #{ENV["GEMFURY_PASSWORD"]}" >> ~/.netrc`
  `git remote add fury https://git.fury.io/#{ENV["TRAVIS_REPO_SLUG"].downcase}.git`

  _owner_name, repo_name = ENV["TRAVIS_REPO_SLUG"].split("/")
  version = File.read("lib/#{repo_name}/version.rb").scan(/\d+.\d+.\d+/).first
  push_response = `git push fury master --force`

  if !push_response.include?("skipped duplicate")
    `git tag #{version}`
    `git push --tags`

    # Notify slack
    if ENV["SLACK_TOKEN"]
      `curl -s -d '#{repo_name} (#{version}) released.' 'https://onehq.slack.com/services/hooks/slackbot?token=#{ENV["SLACK_TOKEN"]}&channel=%23machines'`
    end
  else
    # This version of the gem has already been published.
    # This probably just means the version didn't change in this build
    puts "Version #{version} already published. Skipping release."
  end
else
  # Not releasing.
  puts "Not configured for autorelease."
end
