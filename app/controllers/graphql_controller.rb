# frozen_string_literal: true

class GraphqlController < ApplicationController
  # before_action :check_version
  before_action :authenticate_user!, unless: -> { introspection_query_allowed? }

  def execute
    Honeybadger.context(
      {
        user_id: current_user&.id,
        user_email: current_user&.email,
        query: params[:query],
        variables: prepare_variables(params[:variables]),
        version: request.headers['X-App-Version']
      }
    )

    variables = prepare_variables(params[:variables])
    query = params[:query]
    operation_name = params[:operationName]
    context = { current_user: current_user }
    result = EnhancedOnionSchema.execute(query, variables: variables, context: context, operation_name: operation_name)
    render json: result
  rescue StandardError => e
    Honeybadger.notify(e)
    raise e unless Rails.env.development?

    handle_error_in_development(e)
  end

  private

  def check_version
    version = request.headers['X-App-Version']
    # Just log it or store it for now
    Rails.logger.info "Client App Version: #{version}"
    # return render json: { error: "Please update the app to continue." }, status: 426
  end

  def introspection_query_allowed? = Rails.env.development? && params[:query]&.include?('__schema')

  # Handle variables in form data, JSON body, or a blank value
  def prepare_variables(variables_param)
    case variables_param
    when String
      if variables_param.present?
        JSON.parse(variables_param) || {}
      else
        {}
      end
    when Hash
      variables_param
    when ActionController::Parameters
      variables_param.to_unsafe_hash # GraphQL-Ruby will validate name and type of incoming variables.
    when nil
      {}
    else
      raise ArgumentError, "Unexpected parameter: #{variables_param}"
    end
  end

  def handle_error_in_development(e)
    logger.error e.message
    logger.error e.backtrace.join("\n")
    render json: { errors: [{ message: e.message, backtrace: e.backtrace }], data: {} }, status: 500
  end
end
