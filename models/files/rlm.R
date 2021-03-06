modelInfo <- list(label = "Robust Linear Model",
                  library = "MASS",
                  loop = NULL,
                  type = "Regression",
                  parameters = data.frame(parameter = c("intercept", "psi"),
                                          class = c("logical", "character"),
                                          label = c("intercept", "psi")),
                  grid = function(x, y, len = NULL, search = "grid") 
                    expand.grid(intercept = c(TRUE, FALSE),
                                psi = c("psi.huber", "psi.hampel", "psi.bisquare")),
                  fit = function(x, y, wts, param, lev, last, classProbs, ...) {
                    dat <- if(is.data.frame(x)) x else as.data.frame(x)
                    dat$.outcome <- y
                    
                    psi <- psi.huber # default
                    if (param$psi == "psi.bisquare")
                      psi <- psi.bisquare else
                    if (param$psi == "psi.hampel")
                      psi <- psi.hampel
                    
                    if(!is.null(wts))
                    {
                      if (param$intercept)
                        out <- rlm(.outcome ~ ., data = dat, weights = wts, psi = psi, ...)
                      else
                        out <- rlm(.outcome ~ 0 + ., data = dat, weights = wts, psi = psi,  ...)
                    } else 
                    {
                      if (param$intercept)
                        out <- rlm(.outcome ~ ., data = dat, psi = psi,...)
                      else
                        out <- rlm(.outcome ~ 0 + ., data = dat, psi = psi, ...)
                    }
                    out
                  },
                  predict = function(modelFit, newdata, submodels = NULL) {
                    if(!is.data.frame(newdata)) newdata <- as.data.frame(newdata)
                    predict(modelFit, newdata)
                  },
                  prob = NULL,
                  tags = c("Linear Regression", "Robust Model", "Accepts Case Weights"),
                  sort = function(x) x)
