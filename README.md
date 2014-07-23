# Builder Dash

A build gem for iOS and Android platforms.

## Installing

For the latest build you can run the following from the command line:

```bash
$ curl dash.speedjab.com | sh
```

Alternatively, you can build and install the gem yourself:

```bash
$ gem build builderdash.gemspec
$ gem install builderdash-VERSION.gem
```

## Starting Up

Run `dash dropoff:ios` or `dash dropoff:android` to generate a dummy Dashfile
for the platform of your choice.

The Dashfile has 3 main elements:

  * Platform: specifies how to build the app depending on the platform.
  * Target: defines the signing of the app and thus the receiver of the build.
  * Hooks: a series of scripts that will be executed before and after a successful
    build.

### Platform

It conforms the build specs and can be parametrized with the following
elements:

  * `:ios`
    * `:scheme`: the name of the scheme for building the app.
    * `:workspace`: the file name of the workspace bundle without the
      extension `.xcworkspace`.
    * `:product_name`: the file name of the packaged app without the extension
      `.ipa` in this case.
    * `:product_name`: currently only `xcodebuild` is supported and the value
      is set by default.
  * `:android`
    * `:product_path`: the folder where to find the source code.
    * `:product_name`: the file name of the packaged app without the extension
      `.apk` in this case.
    * `:build_tool`: it can be `:maven` or `:ant`. Both rely on the presence of
      `MAVEN_HOME` or `ANT_HOME` environment variables, respectively. If the
      environment variable is not present, the build will take the executables
      from the system `PATH`.

Samples:

```ruby
platform :ios,
         :scheme => 'outstandingapp',
         :workspace => 'outstandingapp',
         :product_name => 'outstandingapp-ipad'
```

```ruby
platform :android,
         :product_path => 'outstandingapp',
         :product_name => 'outstandingapp-1.0-SNAPSHOT',
         :build_tool => :maven
```

### Target

You can define one or more targets depending on how you want to distribute the
app. Each target is defined by a string that identifies it and with the following
parameters:

  * `configuration`: `:debug` or `:release`. Even `:distribution` is supported
    in iOS builds.
  * `signing_assets`: where to find the signing assets for the build. That is
    certificate and provisioning profile for iOS, or keystore for Android. The
    signing assets have to include a `config.yml` file with the required params
    for installing and using these assets. The location can be one of the following:
    * `:fixed`: this is a particular case for iOS builds where the code signing
      identity will be left as it comes with the project.
    * `:local`: no downloads. Just look for the signing assets at `:path`.
    * `:svn`: download the signing assets from our Subversion repo. At your own
      risk, set an explicit `:username` and `:password` or rely on the presence
      of `SVN_USERNAME` and `SVN_PASSWORD` environment variables.
    * `:s3`: download the signing assets from an Amazon S3 bucket.
  * `upload`: where to upload the packaged app. Currently only `:hockeyapp` is
    supported and it takes `:app_id`, `:team_token` and `:tags` configuration
    variables.

Samples:

```ruby
target 'team/speedjab/enterprise' do
  configuration :debug
  signing_assets :s3, :bucket => 'ci-store', :path => 'certs', :access_key_id => ENV['AWS_ACCESS_KEY_ID'], :secret_access_key => ENV['AWS_SECRET_ACCESS_KEY']
  upload :hockeyapp, :app_id => '*****', :team_token => '*****', :tags => ['speedjab']
end
```

```ruby
target 'team/awesome/development' do
  configuration :release
  signing_assets :local
  upload :hockeyapp, :app_id => '*****', :team_token => '*****', :tags => ['awesome-team', 'speedjab']
end
```

### Hooks

Pre-build and post-build hooks are located at `hooks/pre` and `hooks/post`, relative to your `$CWD`.

## A Complete Build

  * Download and install signing assets.
  * Compile.
  * Package for distribution:
    * Generate .ipa and .dSYM.zip files for iOS.
    * Generate .apk file for Android.
  * Upload to HockeyApp for distribution among stakeholders.

```bash
$ dash touchdown
```

## A Local Build

```bash
$ dash build
```

## Available Tasks

  * `dropoff:ios`
  * `dropoff:android`
  * `build`
  * `touchdown`
