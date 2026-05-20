# `runtime::is_ci`

_No description available._

## Source

```bash
runtime::is_ci() {
  [[ -n "$CI" ]] ||
    [[ -n "$GITHUB_ACTIONS" ]] ||
    [[ -n "$GITLAB_CI" ]] ||
    [[ -n "$CIRCLECI" ]] ||
    [[ -n "$TRAVIS" ]] ||
    [[ -n "$JENKINS_URL" ]] ||
    [[ -n "$BITBUCKET_BUILD_NUMBER" ]] ||
    [[ -n "$TEAMCITY_VERSION" ]] ||
    [[ -n "$DRONE" ]] ||
    [[ -n "$CODEBUILD_BUILD_ID" ]] ||
    [[ -n "$AZURE_HTTP_USER_AGENT" ]] ||  # Azure DevOps
    [[ -n "$BUILDKITE" ]]  # Buildkite
}
```

## Module

[`runtime`](../runtime.md)
