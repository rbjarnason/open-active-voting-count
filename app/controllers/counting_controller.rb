# coding: utf-8

# Copyright (C) 2010-2016 Íbúar ses / Citizens Foundation Iceland
# Authors Robert Bjarnason, Gunnar Grimsson & Gudny Maren Valsdottir
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Affero General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

require Rails.root.join("app","workers","counter.rb")

class CountingController < ApplicationController

#  after_filter :log_session_id

  def counting_info
    respond_to do |format|
      format.json { render :json => {:areas => BudgetBallotArea.all,
                                     area_voter_count: Vote.group(:area_id).distinct.count(:user_id_hash),
                                     total_voter_count: Vote.distinct.count(:user_id_hash) }}
    end
  end

  def start_counting
    if params[:recount] and params[:recount]==true
      BudgetConfig.first.update_attribute(:counting_progress, nil)
    end
    CounterWorker.perform_async(params[:passphrase])
    respond_to do |format|
      format.json { render :json => {:ok => true }}
    end
  end

  def counting_progress
    respond_to do |format|
      format.json { render :json => BudgetConfig.first.counting_progress }
    end
  end

  def download_results_file
    send_file Rails.root.join("results", params[:filename])
  end

  def clear_all_votes
    Vote.delete_all
    respond_to do |format|
      format.json { render :json => {:ok => true }}
    end
  end
end
