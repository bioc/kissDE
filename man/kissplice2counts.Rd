\name{kissplice2counts}
\alias{kissplice2counts}

\title{Conversion of \code{KisSplice} or \code{KisSplice2RefGenome} outputs}

\description{Function that converts \code{KisSplice} (\code{.fa}) output or
\code{KisSplice2RefGenome (tab-delimited)} output to a counts data frame that 
can be used by other functions of the \code{KissDE} package.
}


\usage{
kissplice2counts(fileName, counts = 2, pairedEnd = FALSE, order = NULL, 
    exonicReads = TRUE, k2rg = FALSE, keep = c("All"), remove = NULL)
}


\arguments{
\item{fileName}{a string indicating the path to the \code{KisSplice} 
(\code{.fa}) or the \code{KisSplice2RefGenome} (tab-delimited) file.}

\item{counts}{an interger (0, 1 or 2) corresponding to the \code{KisSplice}
\code{counts} option used (see Details below).}

\item{pairedEnd}{a logical indicating if the data is paired-end (\code{FALSE},
default). If set to \code{TRUE}, the sum of the counts from the pair of reads
will be computed.
It can be used along with \code{counts} option. By default, it is
assumed that, in the \code{KisSplice} command line, two reads of the same pair 
has been inputed as following each other. If it is not the case, see option 
\code{order}.}

\item{order}{a numeric vector indicating the actual order of the corresponding 
paired reads in the columns of the \code{KisSplice} output such that they can 
be summed. This option goes along with \code{pairedEnd = TRUE}, if the read 
pairs are not in the expected order (see \code{pairedEnd} option).
It has as many elements as there are samples in total.
For more information on this parameter, see Details below.}

\item{exonicReads}{a logical indicating if exonic/intronic read counts will be 
kept (\code{TRUE}, default) or discareded (\code{FALSE}). This option only 
works if \code{counts = 2}.}

\item{k2rg}{a logical indicating if the input file is a 
\code{KisSplice2RefGenome} (\code{TRUE}) output or a 
\code{KisSplice} (\code{FALSE}, default) output file.}

\item{keep}{a character vector listing the names of the events to be kept for
the statistical test (for \code{k2rg = TRUE}, analyses all of the events by 
default). The test will be more sensitive the selected events. Event(s) name(s) 
must be part of this list: deletion, insertion, indel, IR, ES, altA, altD, altAD, alt, 
- (for unclassified events). For more information on this parameter, see Details 
below.}

\item{remove}{a character vector listing the names of the events to remove
for the statistical test (for \code{k2rg = TRUE}, does not remove any event by 
default). The test will be more sensitive for the non-selected events.
Event(s) name(s) must be part of this list: deletion, insertion, indel, IR, ES, 
altA, altD, altAD, alt, - (for unclassified events), MULTI.
This option can not be used along with the \code{keep} option, unless ES is
one of the events to be kept. In this case, the \code{remove} option will
work on specific ES events.
For more information on this parameter, see Details below.}
}


\value{\code{kissplice2counts} returns a list of 4 objects:
\item{countsEvents}{a data frame containing several columns: a first column
(\code{events.names}) with the name of the event based on 
\code{KisSplice} notation, a second one (\code{events.length}) containing the
length of the event, and the remaining others columns (\code{counts1} to 
\code{countsN}) with the counts corresponding to the replicates of the 
conditions.}

\item{psiInfo}{a data frame containing information to compute the PSI values.
This data frame is used only when \code{counts} is different from 0.}

\item{exonicReadsInfo}{a logical indicating if \code{exonicReads} are used.}

\item{k2rgFile}{a string containing the \code{KisSplice2RefGenome} path and 
file name. It is equal to NULL if the input file comes from KisSplice.}

Only \code{countsEvents} is shown when \code{\link{kissplice2counts}} output
is printed. 
}


\details{
The \code{counts} parameter:

By default, as in \code{KisSplice}, the \code{counts} option is set
to 0, assuming there is no special counting option. Below, an example of the
upper path counts format output by
\code{KisSplice} when \code{counts} is set to 2:

|AS1_0|SB1_0|S1_0|ASSB1_0|AS2_27|SB2_41|S2_0|ASSB2_21|

AS3_0|SB3_0|S3_0|ASSB3_0|AS4_7|SB4_8|S4_0|ASSB4_2.

In a regular \code{KisSplice} output (\code{counts = 0}), it would be:

|C1_0|C2_47|C3_1|C4_13 (with 47 = 27+41+0-21 and 13 = 7+8+0-2)


The \code{order} parameter:

If the reads corresponding to a paired-end fragments have not been passed to
\code{Kissplice} next to each other, the order needs to be explicitly given to
the \code{\link{kissplice2counts}} function.
For instance, if there are two paired-end samples and if the input in
\code{Kissplice} has been: \code{-r sample1_readPair1.fa} 
\code{-r sample2_readPair1.fa} \code{-r sample1_readPair2.fa}
\code{-r sample2_readPair2.fa},
the input is not organised with the reads of one pair next to each other.
The vector \code{order} to give would be \code{order = c(1, 2, 1, 2)}.


The \code{keep} and \code{remove} parameters:

The options \code{keep} and \code{remove} allow the user to select the type of
alternative splicing events from \code{KisSplice2RefGenome} that have to be 
analysed. To work only with intron retention events, the vector should be: 
\code{keep = c("IR")}. To work on all events except insertions and
deletions, the vector should be \code{remove = c("insertion","deletion")}.
To work specifically on single exon skipping (ES) events (only
one exon can be included or excluded), both \code{keep}
and \code{remove} options must be used. The \code{keep} option should
be set to \code{c("ES")} and the \code{remove} option should be set to
\code{c("alt","altA","altD","altAD","MULTI")}.
}


\examples{
fpath <- system.file("extdata", "output_kissplice_SNV.fa", package="kissDE")
mySNVcounts <- kissplice2counts(fpath, counts = 0, pairedEnd=TRUE)
names(mySNVcounts)
str(mySNVcounts)
head(mySNVcounts$countsEvents)
}
