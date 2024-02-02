# frozen_string_literal: true

namespace :oregon_digital do
  desc 'Re-save work that resource type are audio or video to populate correctly'
  task resave_work_video_audio: :environment do
    puts 'Re-save Work for Audios and Videos'

    # FETCH: Begin to fetch all works in OD2
    puts 'FETCHING - Getting all the works...'
    all_records = get_all_works
    puts 'FETCHING - DONE'

    # SETUP: Create a checking variable to see which one to save for audio or video
    video_check = "http://purl.org/dc/dcmitype/MovingImage"
    audio_check = "http://purl.org/dc/dcmitype/Sound"

    # LOOP: Now loop through each works and find the matching one to resave
    puts 'FINDING - Now finding work to resave that matches either audio or video...'
    all_records.each do |works|
      works.each_with_index do |record, index|
        # CHECK: If the audio or video found, resave
        if (record.resource_type.to_s == video_check) || (record.resource_type.to_s == audio_check)
          record.save
        end
      end
    end
    puts 'FINDING - DONE'
    puts 'RAKE TASK FOR AUDIO AND VIDEO ALL DONE'
  end
end

# METHOD: Getting all the works and store it in an array
def get_all_works
  all_records = [::Generic.all]
  all_records << ::Image.all
  all_records << ::Video.all
  all_records << ::Document.all
  all_records << ::Audio.all

  all_records
end
