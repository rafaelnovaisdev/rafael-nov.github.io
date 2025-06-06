FROM ruby:3.1-slim

# Install essential Linux packages
RUN apt-get update && apt-get install -y \
    build-essential \
    git \
    nodejs \
    && rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /app

# Create a non-root user with the same UID/GID as the host user
RUN addgroup --gid 1000 jekyll && \
    adduser --uid 1000 --gid 1000 --disabled-password --gecos "" jekyll && \
    chown -R jekyll:jekyll /app

# Switch to non-root user
USER jekyll

# Copy Gemfile and Gemfile.lock first (for better caching)
COPY --chown=jekyll:jekyll Gemfile* ./

# Install Jekyll and dependencies
RUN bundle install

# Copy the rest of the application
COPY --chown=jekyll:jekyll . .

# Expose port 4000
EXPOSE 4000

# Use ENTRYPOINT instead of CMD to start the Jekyll server
ENTRYPOINT ["bundle", "exec", "jekyll", "serve", "--host", "0.0.0.0","--incremental"]

HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
  CMD curl -f http://localhost:4000 || exit 1