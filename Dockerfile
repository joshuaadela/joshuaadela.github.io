# Local preview of the GitHub Pages (Jekyll) site.
# Ruby 3.1 matches the github-pages gem (Jekyll 3.9) dependency set.
FROM ruby:3.1-slim

RUN apt-get update \
 && apt-get install -y --no-install-recommends build-essential git \
 && rm -rf /var/lib/apt/lists/*

# Install gems outside the site directory so the mounted source (and the
# host's macOS-only Gemfile.lock) never conflicts with the container's bundle.
WORKDIR /gems
COPY Gemfile Gemfile.lock ./
# Jekyll 3.9 on Ruby 3.x needs webrick for `jekyll serve`; add it in-image only.
RUN echo 'gem "webrick", "~> 1.8"' >> Gemfile \
 && bundle lock --add-platform ruby x86_64-linux aarch64-linux \
 && bundle install --jobs 4

ENV BUNDLE_GEMFILE=/gems/Gemfile \
    JEKYLL_ENV=development \
    PAGES_REPO_NWO=joshuaadela/joshuaadela.github.io

WORKDIR /srv/jekyll
COPY . .

EXPOSE 4000 35729
CMD ["bundle", "exec", "jekyll", "serve", "--host", "0.0.0.0", "--livereload", "--force_polling"]
