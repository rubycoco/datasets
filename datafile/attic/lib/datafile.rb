
class Script
  include LogUtils::Logging

  def initialize( proc )
    @proc = proc
  end

  def call
    logger.info( "[script] calling calc block" )
    @proc.call
  end

  def dump
    puts "  script: #{@proc.inspect}"
  end
end  ## class Script



### todo/check: use Script for Inline too?? - why, why not???
###  - use setup/pre/before and post/after or something??
##  - note: for now always is pre/before

class Inline
  include LogUtils::Logging

  def initialize( proc )
    @proc = proc
  end

  def call
    logger.info( "[inline] calling script block" )
    @proc.call
  end

  def dump
    puts "  script: #{@proc.inspect}"
  end
end  ## class Inline


class Datafile


  ## another convenience method - use like Datafile.load()
  def self.load( code )
    builder = Builder.new
    builder.instance_eval( code )

    # Note: return datafile (of course, NOT the builder)
    #  if you want a builder use Datafile::Builder ;-)
    datafile = builder.datafile
    ## check for auto-configure (just guessing)
    ##   zip or file worker
    datafile.guess_file_or_zip_worker
    datafile
  end


  def guess_file_or_zip_worker   ## change/rename to configure_file_or_zip_worker - why? why not??
    ## if opts file or zip exists do NOT change (assume set manually)
    return  if @opts[:file] || @opts[:zip]

    ## for now only change if single (just 1) dataset and it's present
    if @datasets.size == 1 && @datasets[0].file?
      puts "  bingo!! assume (in-situ) datafile; use file workers"
      @worker = FileWorker.new( self )
    end
  end



  attr_reader   :scripts    ## calc(ulation) scripts (calc blocks)
  attr_reader   :inlines    ## inline script blocks  -- use before?? run before datasets
  attr_reader   :name
  attr_reader   :deps       ## dep(endencies)

  def initialize( opts={} )
    @scripts  = []   ## calculation scripts (calc blocks)
    @inlines  = []   ## inline (setup) scripts (run before reading datasets)

    ## (target)name - return nil if noname (set/defined/assigned)
    @name  = opts[:name] || nil
    ## deps (dependencies) - note: always returns an array (empty array if no deps)
    @deps  = opts[:deps] || []
  end

  def run
    logger.info( "[datafile] begin - run" )
    download     # step 1 - download zips for datasets
    read         # step 2 - read in datasets from zips  - note: includes running inlines
    calc         # step 3 - run calc(ulations) scripts
    logger.info( "[datafile] end - run" )
  end

  def calc
    logger.info( "[datafile] calc" )
    @worker.calc
  end

=begin
  def download_world   ## only dl world datasets (skip all others)
    logger.info( "[datafile] dowload world datasets" )
    @datasets.each do |dataset|
      if dataset.kind_of? WorldDataset
        dataset.download()
      else
        # skip all others
      end
    end
  end

  def download_beer   ## only dl beer datasets (skip all others)
    logger.info( "[datafile] dowload beer datasets" )
    @datasets.each do |dataset|
      if dataset.kind_of? BeerDataset
        dataset.download()
      else
        # skip all others
      end
    end
  end

  def download_football   ## only dl football datasets (skip all others)
    logger.info( "[datafile] dowload football datasets" )
    @datasets.each do |dataset|
      if dataset.kind_of? FootballDataset
        dataset.download()
      else
        # skip all others
      end
    end
  end
=end


=begin
  def read_world
    logger.info( "[datafile] read world datasets" )
    @datasets.each do |dataset|
      if dataset.kind_of?( WorldDataset )
        dataset.read()
      else
        # skip all others
      end
    end
  end

  def read_beer
    logger.info( "[datafile] read beer datasets" )
    @datasets.each do |dataset|
      if dataset.kind_of?( BeerDataset )
        dataset.read()
      else
        # skip all others
      end
    end
  end

  def read_football
    logger.info( "[datafile] read football datasets" )
    @datasets.each do |dataset|
      if dataset.kind_of?( FootballDataset )
        dataset.read()
      else
        # skip all others
      end
    end
  end
=end

end
