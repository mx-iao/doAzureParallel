# Run this test for users to make sure the github package
# install feature of doAzureParallel are still working
context("github package install scenario test")
test_that("single github package install Test", {
  testthat::skip("Live test")
  testthat::skip_on_travis()
  credentialsFileName <- "credentials.json"
  clusterFileName <- "cluster.json"

  doAzureParallel::generateCredentialsConfig(credentialsFileName)
  doAzureParallel::generateClusterConfig(clusterFileName)

  # set your credentials
  doAzureParallel::setCredentials(credentialsFileName)
  cluster <- doAzureParallel::makeCluster(clusterFileName)
  doAzureParallel::registerDoAzureParallel(cluster)

  opt <- list(wait = TRUE)
  '%dopar%' <- foreach::'%dopar%'
  githubPackages <- 'Azure/doAzureParallel'
  res <-
    foreach::foreach(
      i = 1:4,
      github = githubPackages,
      .options.azure = opt
    ) %dopar% {
      "doAzureParallel" %in% rownames(installed.packages()) &&
      "rAzureBatch" %in% rownames(installed.packages())
    }

  # verify the job result is correct
  testthat::expect_equal(length(res),
                         4)

  testthat::expect_equal(res,
                         list(TRUE, TRUE, TRUE, TRUE))
})

test_that("multiple github package install Test", {
  testthat::skip("Live test")
  testthat::skip_on_travis()
  credentialsFileName <- "credentials.json"
  clusterFileName <- "cluster.json"

  doAzureParallel::generateCredentialsConfig(credentialsFileName)
  doAzureParallel::generateClusterConfig(clusterFileName)

  # set your credentials
  doAzureParallel::setCredentials(credentialsFileName)
  cluster <- doAzureParallel::makeCluster(clusterFileName)
  doAzureParallel::registerDoAzureParallel(cluster)

  opt <- list(wait = TRUE)
  '%dopar%' <- foreach::'%dopar%'
  githubPackages <- c('Azure/doAzureParallel', 'twitter/AnomalyDetection', 'hadley/dplyr')
  res <-
    foreach::foreach(
      i = 1:3,
      github = githubPackages,
      .options.azure = opt
    ) %dopar% {
      c("doAzureParallel" %in% rownames(installed.packages()),
        "AnomalyDetection" %in% rownames(installed.packages()),
        "dplyr" %in% rownames(installed.packages()))
    }

  # verify the job result is correct
  testthat::expect_equal(length(res),
                         3)

  testthat::expect_equal(res,
                         list(c(TRUE, TRUE, TRUE),
                              c(TRUE, TRUE, TRUE),
                              c(TRUE, TRUE, TRUE)))
})

test_that("pool multiple github package install Test", {
  testthat::skip("Live test")
  testthat::skip_on_travis()
  credentialsFileName <- "credentials.json"
  clusterFileName <- "cluster.json"

  githubPackages <- c('Azure/doAzureParallel', 'twitter/AnomalyDetection', 'hadley/dplyr')

  doAzureParallel::generateCredentialsConfig(credentialsFileName)
  doAzureParallel::generateClusterConfig(clusterFileName)

  config <- jsonlite::fromJSON(clusterFileName)
  config$name <- "multipleGithubPackage"
  config$poolSize$dedicatedNodes$min <- 0
  config$poolSize$dedicatedNodes$max <- 0
  config$poolSize$lowPriorityNodes$min <- 1
  config$poolSize$lowPriorityNodes$max <- 1
  config$rPackages$github <- c('Azure/doAzureParallel', 'twitter/AnomalyDetection', 'hadley/dplyr')
  configJson <- jsonlite::toJSON(config, auto_unbox = TRUE, pretty = TRUE)
  write(configJson, file = paste0(getwd(), "/", clusterFileName))

  # set your credentials
  doAzureParallel::setCredentials(credentialsFileName)
  cluster <- doAzureParallel::makeCluster(clusterFileName)
  doAzureParallel::registerDoAzureParallel(cluster)

  '%dopar%' <- foreach::'%dopar%'
  res <-
    foreach::foreach(i = 1:3) %dopar% {
      c("doAzureParallel" %in% rownames(installed.packages()),
        "AnomalyDetection" %in% rownames(installed.packages()),
        "dplyr" %in% rownames(installed.packages()))
    }

  # verify the job result is correct
  testthat::expect_equal(length(res),
                         3)

  testthat::expect_equal(res,
                         list(c(TRUE, TRUE, TRUE),
                              c(TRUE, TRUE, TRUE),
                              c(TRUE, TRUE, TRUE)))
})
