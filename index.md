## Welcome to my R Coding Club tutorial on Package Literacy in R!

`R` is an incredibly powerful tool, but let's face it - the true magic of `R` lies in the rich ecosystem of packages available. Think of each `R` package as a specialised toolbox, with each one tailored for specific tasks. From wrangling messy data sets to building beautiful visualisations or running complex statistical models, there is likely a package that can make your life easier. Yet from this we can be susceptible to something called **package fatigue** (I may coin this term as my own). With a wide range of choices comes an uncertainty as to what to use. Alas, this tutorial is here to help you navigate some of the less used packages to help you build confidence and get to grips with the package world of `R`. 

### Tutorial Aims

#### <a href="#section1"> 1. Introduction</a>

#### <a href="#section2"> 2. Using `data.table`</a>

#### <a href="#section3"> 3. Efficient workflows and best practices</a>

#### <a href="#section4"> 4. Exercise</a>

---------------------------

You can get all of the resources for this tutorial from <a href="https://github.com/EdDataScienceEES/tutorial-jackegriffin.git">this GitHub repository</a>. Clone and download the repo as a zip file, then unzip it.


## <a name="section1"> Introduction</a>


Today we will be using data from the **Living Planet Index** which is free, open source data and is a key indicator used to measure the state of global biodiversity by tracking changes in the population sizes of vertebrate species over time. Information regarding the Living Planet Index's licensing policy can be found in the GitHub repositories **README**.

The `tidyverse` is a widely used and powerful set of R packages designed for data analysis, but it is not without its drawbacks. One of the main concerns with the `tidyverse` is its performance on very large datasets. Since `tidyverse` packages like `dplyr` process data in memory, they can struggle when working with datasets that exceed the available memory. This can lead to slow performance compared to alternatives like `data.table`, which is optimized for speed and memory efficiency. In this tutorial you will be using specialised packages such as: `data.table`, `purrr`, `broom`, `janitor`, `lubridate`

So, let's make a start and start thinking about packages we may have not even heard of. Open `RStudio`, clone into the GitHub repository and create a new script by clicking on `File/ New File/ R Script` set the working directory and we are ready to go. 

## <a name="section2"> Using `data.table`</a>


