## Welcome to my R Coding Club tutorial on Package Literacy in R!

`R` is an incredibly powerful tool, but let's face it - the true magic of `R` lies in the rich ecosystem of packages available. Think of each `R` package as a specialised toolbox, with each one tailored for specific tasks. From wrangling messy data sets to building beautiful visualisations or running complex statistical models, there is likely a package that can make your life easier. Yet from this we can be susceptible to something called **package fatigue** (I may coin this term as my own). With a wide range of choices comes an uncertainty as to what to use. Alas, this tutorial is here to help you navigate some of the commonly used packages to help you build confidence and get to grips with the package world of `R`. 

### Tutorial Aims

#### <a href="#section1"> 1. Introduction to package literacy</a>

#### <a href="#section2"> 2. Advanced packages</a>

#### <a href="#section3"> 3. Efficient workflows and best practices</a>

#### <a href="#section4"> 4. Exercise</a>

---------------------------

You can get all of the resources for this tutorial from <a href="https://github.com/EdDataScienceEES/tutorial-jackegriffin.git">this GitHub repository</a>. Clone and download the repo as a zip file, then unzip it.


## <a name="section1"> Introduction</a>


Today we will be using data from the **Living Planet Index** which is free, open source data and is a key indicator used to measure the state of global biodiversity by tracking changes in the population sizes of vertebrate species over time. Information regarding the Living Planet Index's licensing policy can be found in the GitHub repositories **README**.
This tutorial is aimed to get you thinking of packages
So, let's make a start. Open `RStudio`, clone into the GitHub repository and create a new script by clicking on `File/ New File/ R Script` set the working directory and we are ready to go. You can surround package names, functions, actions ("File/ New...") and small chunks of code with backticks, which defines them as inline code blocks and makes them stand out among the text, e.g. `ggplot2`.

When you have a larger chunk of code, you can paste the whole code in the `Markdown` document and add three backticks on the line before the code chunks starts and on the line after the code chunks ends. After the three backticks that go before your code chunk starts, you can specify in which language the code is written, in our case `R`.

To find the backticks on your keyboard, look towards the top left corner on a Windows computer, perhaps just above `Tab` and before the number one key. On a Mac, look around the left `Shift` key. You can also just copy the backticks from below.

