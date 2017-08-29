function a = pdf_truncnorm(x,mu,sigma) 

normpdf(x,mu,sigma) ./ (1-normcdf(0,mu,sigma));
