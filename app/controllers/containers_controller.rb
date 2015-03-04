class ContainersController < ApplicationController
  before_action :set_container, only: [:show, :edit, :update, :destroy, :submit, :copy, :results, :stl, :paraview]

  # GET /containers
  # GET /containers.json
  def index
    #FIXME: we preload the jobs since we have to look at the jobs for status info
    # the problem is all of the status presenter methods on Container are actually doing
    # queries against the jobs table, but those queries never load the Job model objects
    # which means that after_find is never triggered for each job so the job record cached statuses
    # never get updated. we need a cleaner solution for all of this
    @containers = Container.preload(:jobs).all
  end

  # GET /containers/1
  # GET /containers/1.json
  def show
  end

  # GET /containers/new
  def new
    @container = Container.new
    @container.inlets.build
    @container.outlets.build
  end

  # GET /containers/1/edit
  def edit
  end

  # POST /containers
  # POST /containers.json
  def create
    @container = Container.new(container_params)

    respond_to do |format|
      if @container.save
        format.html { redirect_to @container, notice: 'Container was successfully created.' }
        format.json { render action: 'show', status: :created, location: @container }
      else
        format.html { render action: 'new' }
        format.json { render json: @container.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /containers/1
  # PATCH/PUT /containers/1.json
  def update
    respond_to do |format|
      if @container.update(container_params)
        format.html { redirect_to @container, notice: 'Container was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @container.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /containers/1
  # DELETE /containers/1.json
  def destroy
    @container.destroy
    respond_to do |format|
      format.html { redirect_to containers_url }
      format.json { head :no_content }
    end
  end

  # PUT /containers/1/submit
  def submit
    if @container.submitted?
      respond_to do |format|
        format.html { redirect_to containers_url, alert: 'Container simulation has already been submitted!' }
        format.json { head :no_content }
      end
    else
      #TODO: add error handling
      @container.submit

      respond_to do |format|
        format.html { redirect_to containers_url, notice: 'Container simulation submitted.' }
        format.json { head :no_content }
      end
    end
  end

  # PUT /containers/1/copy
  def copy
    @new_container = @container.copy

    respond_to do |format|
      if @new_container.save
        format.html { redirect_to @new_container, notice: 'Container was successfully copied.' }
        format.json { render action: 'show', status: :created, location: @new_container }
      else
        format.html { redirect_to containers_url, alert: 'Failed to copy container!' }
        format.json { head :no_content }
      end
    end
  end

  # GET /containers/1/results
  def results
  end

  # GET /containers/1/stl
  def stl
  end

  # GET /containers/1/paraview
  def paraview
    foam_file = "#{@container.staged_dir}/out.foam"

    outdir = File.join(ENV["RAILS_DATAROOT"], "vnc", "paraview")
    xdir = Rails.root.join("jobs", "vnc", "paraview")
    jnlp = OSC::VNC::Session.new(outdir: outdir, xdir: xdir, cluster: 'glenn', walltime: '00:30:00', datafile: foam_file).run.to_jnlp

    send_data jnlp.force_encoding('binary'), type: :jnlp, disposition: "attachment", filename: "paraview.jnlp"
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_container
      @container = Container.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def container_params
      params.require(:container).permit!
    end
end
