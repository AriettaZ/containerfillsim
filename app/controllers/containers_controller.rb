class ContainersController < ApplicationController
  before_action :update_containers

  # GET /containers
  # GET /containers.json
  def index
    @containers = Container.all
  end

  # GET /containers/1
  # GET /containers/1.json
  def show
    set_container
  end

  # GET /containers/new
  def new
    @container = Container.new
    @container.build_wall
    @container.inlets.build
  end

  # GET /containers/1/edit
  def edit
    set_container
  end

  # POST /containers
  # POST /containers.json
  def create
    @container = Container.new(container_params)

    respond_to do |format|
      if @container.save
        format.html { redirect_to @container, notice: 'Container was successfully created.' }
        format.json { render :show, status: :created, location: @container }
      else
        format.html { render :new }
        format.json { render json: @container.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /containers/1
  # PATCH/PUT /containers/1.json
  def update
    set_container

    respond_to do |format|
      if @container.update(container_params)
        format.html { redirect_to @container, notice: 'Container was successfully updated.' }
        format.json { render :show, status: :ok, location: @container }
      else
        format.html { render :edit }
        format.json { render json: @container.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /containers/1
  # DELETE /containers/1.json
  def destroy
    set_container

    respond_to do |format|
      if @container.destroy
        format.html { redirect_to containers_url, notice: 'Container was successfully destroyed.' }
        format.json { head :no_content }
      else
        format.html { redirect_to containers_url, alert: "Container failed to be destroyed: #{@container.errors.to_a}" }
        format.json { render json: @container.errors, status: :internal_server_error }
      end
    end
  end

  # PUT /containers/1/submit
  # PUT /containers/1/submit.json
  def submit
    set_container

    respond_to do |format|
      if !@container.not_submitted?
        format.html { redirect_to containers_url, alert: 'Container has already been submitted.' }
        format.json { head :no_content }
      elsif @container.submit
        format.html { redirect_to containers_url, notice: 'Container was successfully submitted.' }
        format.json { head :no_content }
      else
        format.html { redirect_to containers_url, alert: "Container failed to be submitted: #{@container.errors.to_a}" }
        format.json { render json: @container.errors, status: :internal_server_error }
      end
    end
  end

  # PUT /containers/1/copy
  def copy
    set_container
    @container = @container.copy

    respond_to do |format|
      if @container.save
        format.html { redirect_to @container, notice: 'Container was successfully copied.' }
        format.json { render :show, status: :created, location: @container }
      else
        format.html { redirect_to containers_url, alert: "Container failed to be copied: #{@container.errors.to_a}" }
        format.json { render json: @container.errors, status: :unprocessable_entity }
      end
    end
  end

  private
    def update_containers
      Container.active.each(&:update_status)
    end

    # Use callbacks to share common setup or constraints between actions.
    def set_container
      @container = Container.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def container_params
      params.require(:container).permit!
    end
end
