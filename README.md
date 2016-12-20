# Super Serious Setup

## Goals

* set up a new application with a single command
* deploy on mobile
* monitoring on mobile
* connect metrics to logs
* cloud agnostic
* automated dns and service discovery
* run dockerized apps

## Requirements

Terraform

    $ brew install terraform

## Installation

```bash
# adds sss executable to /usr/local/bin
$ ./install
```

## First time setup

```bash
$ cd /path/to/app
$ sss deploy
```

## Deploy

```bash
$ sss deploy
```

## Monitor

```bash
$ sss monitor
```

## Load Kibana Logs

```bash
$ sss logs
```

## Slack integration for mobile deploys


```bash
$ sss slack
```

## Teardown

```bash
$ sss teardown
```
