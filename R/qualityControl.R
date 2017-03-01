qualityControl <- function(countsData, conditions, storeFigs=FALSE) {
	
	options(warn=-1)  # suppress the warning for the users
	
	if (storeFigs == FALSE) {
		pathToFigs <- NA
	} else {
		if (isTRUE(storeFigs)) {
			pathToFigs <- "kissDEFigures"
		} else {
			pathToFigs <- storeFigs
		}
	}
	
	# create a new folder if it doesn't exist
	if (!is.na(pathToFigs)) {
		find <- paste("find", pathToFigs)
		d <- system(find, TRUE, ignore.stderr=TRUE)
		if (length(d) == 0) { 
			command <- paste("mkdir", pathToFigs)
			system(command, ignore.stderr=TRUE)
		}
	}
	
	###################################################
	### code chunk number 1: Read and prepare data
	###################################################
	listData <- .readAndPrepareData(countsData, conditions)
	countsData <- listData$countsData
	conds <- listData$conditions
	dimns <- listData$dim
	n <- listData$n
	nr <- listData$nr
	
	###################################################
	### select events with highest variance (on PSI)
	###################################################
	countsData2 <- reshape(countsData[, c(1,(dimns):(dimns + length(conds)))], timevar="Path", idvar="ID", direction="wide")
	for (i in 1:n){
		for (j in 1:nr[i]){
			countsData2$PSI <- countsData2[,(1+j+sum(nr[0:(i-1)]))]/
				(countsData2[,(1+j+sum(nr[0:(i-1)]))] + countsData2[,(1+sum(nr)+j+sum(nr[0:(i-1)]))])
			# replace PSI by NA if count less or equal to 10 reads for the 2 isoforms
			indexNA <- intersect(which(countsData2[,(1+j+sum(nr[0:(i-1)]))] < 10), which(countsData2[,(1+sum(nr)+j+sum(nr[0:(i-1)]))] < 10))
			countsData2$PSI[indexNA] <- NA
			colnames(countsData2)[9+j+(i-1)*2] <- paste(paste0("Cond",i),paste0("repl",j),sep="_")
		}
	}
	countsData2$vars <- apply(as.matrix(countsData2[, 10:(9 + length(conds))]), 1, var, na.rm=TRUE)
	ntop <- min(500, dim(countsData2)[1])
	selectntop <- order(countsData2$vars, decreasing=TRUE)[seq_len(ntop)]
	countsData2Selected <- countsData2[selectntop,]
	# remove all NAs
	countsData2Selected <- countsData2Selected[complete.cases(countsData2Selected[, 10:(9 + length(conds))]),]
	
	###################################################
	### code chunk number 3: heatmap
	###################################################
	if (storeFigs == FALSE) {
		heatmap.2(as.matrix(as.dist(1 - cor(countsData2Selected[, 10:(9 + length(conds))]))), margins=c(10, 10), 
							cexRow=1, cexCol=1, density.info="none", trace="none")
		par(ask=TRUE)
	} else {
		filename <- paste(storeFigs, "/heatmap.png", sep="")
		png(filename)
		heatmap.2(as.matrix(as.dist(1 - cor(countsData2Selected[, 10:(9 + length(conds))]))), margins=c(10, 10), 
							cexRow=1, cexCol=1, density.info="none", trace="none")
		void <- dev.off()
	}
	
	###################################################
	### PCA plot
	###################################################
	pca <- prcomp(t(countsData2Selected[, 10:(9 + length(conds))]))
	fac <- factor(conds)
	colorpalette <- c("#192823", "#DD1E2F", "#EBB035", "#06A2CB", "#218559", "#D0C6B1")
	colors <- colorpalette[1:n]
	pc1var <- round(summary(pca)$importance[2,1]*100, digits=1)
	pc2var <- round(summary(pca)$importance[2,2]*100, digits=1)
	pc1lab <- paste0("PC1 (",as.character(pc1var),"%)")
	pc2lab <- paste0("PC2 (",as.character(pc2var),"%)")
	if (storeFigs == FALSE) {
		par(oma=c(2, 1, 1, 1))
		plot(PC2~PC1, data=as.data.frame(pca$x), bg=colors[fac], pch=21, xlab=pc1lab, ylab=pc2lab, main="PCA plot")
		par(fig=c(0, 1, 0, 1), oma=c(0, 0, 0, 0), mar=c(0, 0, 0, 0), new=TRUE)
		plot(0, 0, type="n", bty="n", xaxt="n", yaxt="n")
		legend("bottom", legend=levels(fac), xpd=TRUE, horiz=TRUE, inset=c(0, 0), bty="n", pch=20, col=colors)
	} else {
		filename <- paste(storeFigs, "/pca.png", sep="")
		png(filename)
		par(oma=c(2, 1, 1, 1))
		plot(PC2~PC1, data=as.data.frame(pca$x), bg=colors[fac], pch=21, xlab=pc1lab, ylab=pc2lab, main="PCA plot")
		par(fig=c(0, 1, 0, 1), oma=c(0, 0, 0, 0), mar=c(0, 0, 0, 0), new=TRUE)
		plot(0, 0, type="n", bty="n", xaxt="n", yaxt="n")
		legend("bottom", legend=levels(fac), xpd=TRUE, horiz=TRUE, inset=c(0, 0), bty="n", pch=20, col=colors)
		void <- dev.off()
	}
	
	# ###################################################
	# ### code chunk number 4: intra-group and inter-group-variance
	# ###################################################
	# # Mean and variance over all conditions and replicates (normalized counts!)
	# countsData$mn <- rowMeans(countsData[, (dimns + 1):(dimns + length(conds))])
	# countsData$var <- apply(countsData[, (dimns + 1):(dimns + length(conds))], 1, var)
	# # correction term
	# nbAll <- sum(nr)  # number of all observations in all groups
	# countsData$ct <- rowSums(countsData[, (dimns + 1):(dimns + length(conds))])^2 / nbAll
	# # sum of squares between groups
	# countsData$ss <- rowSums(countsData[, (dimns + 1):(dimns + length(conds) / n)])^2 / nr[1] + rowSums(countsData[, ((dimns + 1) + length(conds) / n):(dimns + length(conds))])^2 / nr[2]
	# # substract the correction term from the SS and divide by the degrees of 
	# df <- 1 # freedom(groups); here: df=2-1=1
	# countsData$varInter <- (countsData$ss - countsData$ct) / df
	# # intra-variability 
	# countsData$varC1 <- apply(countsData[, (dimns + 1):(dimns + nr[1])], 1, var)
	# countsData$varC2 <- apply(countsData[, ((dimns + 1) + nr[1]):(dimns + nr[2] + nr[1])], 1, var)
	# countsData$varIntra <- rowMeans(data.frame(countsData$varC1, countsData$varC2))
	# 
	# ###################################################
	# ### code chunk number 5: intra-vs-inter
	# ###################################################
	# if (storeFigs == FALSE) {
	#   plot(x=countsData$varIntra, y=countsData$varInter, xlab="Intra-variability", ylab="Inter-variability", las=1, log="xy")
	#   abline(a=0, b=1, col=2, lty=2, lwd=2)
	# } else {
	#   filename <- paste(storeFigs, "/InterIntraVariability.png", sep="")
	#   png(filename)
	#   plot(x=countsData$varIntra, y=countsData$varInter, xlab="Intra-variability", ylab="Inter-variability", las=1, log="xy")
	#   abline(a=0, b=1, col=2, lty=2, lwd=2)
	#   void <- dev.off()
	# }
}

