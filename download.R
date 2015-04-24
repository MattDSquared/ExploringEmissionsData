# =============================================================================
# Download data files
# downloads binary .zip file from https:// on windows machine
# unzips the file and returns file names of the unzipped files
# doesn't download the file if it already exists, but does overwrite unzipped
# files.
# =============================================================================
dldata <- function(dlfilepath, dataURL){
    
    if (!file.exists(dlfilepath)){ 
        # set browser to download file through IE protocol (for https)
        setInternet2(use = TRUE)
        download.file(dataURL, destfile = dlfilepath, mode="wb")
    } else {
        message("using previously downloaded data.")
    }
    
    # unzip, overwrites data
    unzip(dlfilepath)
}