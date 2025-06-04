class CareerController < ApplicationController
  before_action :find_project, only: [:new, :create]

  def new
    # This will render the form to enter Name, Qualification, Experience, and Position.
  end

  def create
    begin
      # Fetching the parameters from the form submission
      name = params[:name]
      qualification = params[:qualification]
      experience = params[:experience]
      position = params[:position]
      resume = params[:resume]

      logger.debug "Received Parameters: #{params.inspect}"  # Log the received parameters

      # Create a new issue in the project
      issue = Issue.new(
        project: @project,
        subject: "Issue For #{position}",
        description: "Name: #{name}\nQualification: #{qualification}\nExperience: #{experience}\nPosition: #{position}",
        tracker: Tracker.find_by(name: 'career'),
        author: User.current
      )

      # Log the issue object before saving
      logger.debug "Issue Object: #{issue.inspect}"

      # Custom field assignment
      issue.custom_field_values = {
        1 => qualification,
        2 => experience,
        3 => position
      }

      if issue.save
        logger.debug "Issue saved successfully: #{issue.id}"

        # Handling the uploaded resume (if provided)
        if resume
          if resume.respond_to?(:original_filename) && resume.size > 0
            attachment = Attachment.new(
              container: issue,
              file: resume,
              filename: resume.original_filename,
              author: User.current
            )

            logger.debug "Attempting to save attachment with filename: #{resume.original_filename}"

            if attachment.save
              flash[:notice] = "Attachment uploaded successfully!"
            else
              flash[:error] = "Failed to save attachment: #{attachment.errors.full_messages.join(', ')}"
              return render :new
            end
          else
            flash[:error] = "Invalid file. Please upload a valid file."
            return render :new
          end
        end

        flash[:notice] = "Career page created successfully!"
        render :new
      else
        flash[:error] = "Failed to create the issue. Please try again."
        render :new
      end

    rescue ActiveRecord::StaleObjectError => e
      flash[:error] = "This issue was updated by someone else. Please reload and try again."
      logger.error "StaleObjectError: #{e.message}"
      render :new

    rescue ActiveRecord::RecordInvalid => e
      flash[:error] = "Failed to create the issue due to validation errors: #{e.record.errors.full_messages.join(', ')}"
      render :new

    rescue StandardError => e
      flash[:error] = "An unexpected error occurred: #{e.message}"
      logger.error "Error in CareerController#create: #{e.message}"
      logger.error e.backtrace.join("\n")
      render :new
    end
  end

  private

  def find_project
    # Fetch the project by name "pune-office-baner-site"
    @project = Project.find_by(identifier: 'kolhapur-office-sterling-tower')  # Use the project name

    unless @project
      flash[:error] = "Project 'kolhapur-office-sterling-tower' not found."
      redirect_to projects_path  # Redirect to the list of projects if not found
    end
  end
end
