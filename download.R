# =============================================================================
# Download data files
# downloads binary .zip file from https:// on windows machine
# unzips the file and returns file names of the unzipped files
# doesn't download the file if it already exists, but does overwrite unzipped
# files.
# =============================================================================
dldata <- function(dlfilepath, dlfilename, dataURL){
    
    dlfilepath = file.path(getwd(),dlfilepath)
    dlfullfilename = file.path(dlfilepath, dlfilename)
    
    dir.create(dlfilepath, showWarnings = FALSE)
    
    if (!file.exists(dlfullfilename)){ 
        # set browser to download file through IE protocol (for https)
        setInternet2(use = TRUE)
        download.file(dataURL, destfile = dlfullfilename, mode="wb")
    } else {
        message("Using previously downloaded data.")
    }
    
    # unzip, overwrites data
    message("Unzipping original zip file...")
    unzip(dlfullfilename,exdir = dlfilepath)
}