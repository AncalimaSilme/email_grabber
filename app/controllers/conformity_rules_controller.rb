# coding: utf-8

class ConformityRulesController < ApplicationController
  layout 'admin'

  def index
    @conformity_rules = ConformityRule.all
  end

  def create
    @conformity_rule = ConformityRule.new(params[:conformity_rule])
    if @conformity_rule.save()
      flash[:notice] = l(:notice_successful_create)
    else
      flash[:error] = 'Не удалось создать правило сопоставления'
    end

    redirect_to conformity_rules_path
  end

  def destroy
    @conformity_rule = ConformityRule.find(params[:id])
    if @conformity_rule.destroy()
      flash[:notice] = l(:notice_successful_delete)
    else
      flash[:error] = 'Не удалось удалить правило сопоставления'
    end

    redirect_to conformity_rules_path
  end
end