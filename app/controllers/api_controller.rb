# encoding: utf-8

class ApiController < ApplicationController
  protect_from_forgery with: :null_session
end