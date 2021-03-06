require_relative '../../scheduler/scheduler'

class Scheduler < ActiveRecord::Base
	attr_accessible :id, :name

	def load
		people = []
		User.all.each do |user|
			instruments = []
			Instrument.all.each do |instr|
				instruments.push (TW2::Instrument.new instr.instrument_name.value) if instr.user == user
			end
			spaces = []
			Space.all.each do |sp|
				spaces.push (TW2::Space.new sp.soundproofness.to_i) if sp.user == user
			end

			p = TW2::Person.new user.username, TW2::AvailableTime.new(user.available_time.value)
			p.instruments.concat instruments
			p.spaces.concat spaces
			people.push p
		end

		demos = []
		ProjectRequirement.all.each do |req|
			time = TW2::AvailableTime.new req.user.available_time.value

			instruments = []
			req.instrument_requirements.each do |instr_req|
				instruments.push instr_req.instrument_name.value
			end

			demos.push TW2::Demo.new(name: req.name,
									 duration: req.duration,
									 schedule: time,
								 	 required_instruments: instruments,
									 required_space: req.soundproofness.to_i)
		end

		@s = TW2::Scheduler.new people, demos
		@s.calculate
	end

	def run #This currently does not work, so do not use it!
		#@s.calculate
	end
end