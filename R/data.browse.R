
data.browse <-
    function(all = TRUE)
{
    available <-
        if (all) data(package = .packages(all.available = TRUE))
        else data()
    data <- as.data.frame(available$results[, c(3, 1, 4)])
    colnames(data) <-
        c("Data", "Package", "Description")
    ans <- qdataview(data)
    qresizeColumnsToContents(ans)
    qsetSortingEnabled(ans, TRUE)
    ans
}
