# frozen_string_literal: true

RSpec.describe OregonDigital::VerifyDerivativesService do
  let(:work) { double }
  let(:service) { described_class.new({ work: work, solr_doc: solr_doc }) }
  let(:solr_doc) do
    {
      'id' => pid,
      'thumbnail_path_ss' => 'path',
      'file_set_ids_ssim' => ["f0#{pid}"]
    }
  end
  let(:pid) { 'df70jh899' }
  let(:file_set) do
    instance_double(
      'FileSet',
      id: 'bn999672v',
      uri: 'http://127.0.0.1/rest/fake/bn/99/96/72/bn999672v',
      extracted_text: 'banana',
      mime_type: 'image/png'
    )
  end
  let(:content_path) { 'spec/fixtures/test.jpg' }

  before do
    allow(work).to receive(:class).and_return(Image)
    allow(file_set).to receive(:class).and_return(FileSet)
    allow(Hyrax::DerivativePath).to receive(:derivatives_for_reference).and_return(all_derivative_paths)
    allow(work).to receive(:file_sets).and_return([file_set])
  end

  # rubocop:disable RSpec/NestedGroups
  describe 'verify' do
    let(:all_derivative_paths) { [] }

    context 'when there is no file set' do
      before do
        allow(work).to receive(:file_sets).and_return([])
      end

      context 'when the asset is an Image' do
        it 'returns a warning' do
          expect(service.verify).to eq({ derivatives: ['no file set'] })
        end
      end

      context 'when the asset is a Generic' do
        before do
          allow(work).to receive(:class).and_return(Generic)
        end

        it 'returns no errors' do
          expect(service.verify).to eq({ derivatives: [] })
        end
      end
    end
    # rubocop:enable RSpec/NestedGroups

    context 'when the file set was not indexed' do
      let(:all_derivative_paths) { ['/data/tmp/shared/derivatives/c2/47/ds/08/x-jp2-0000.jp2', '/data/tmp/shared/derivatives/c2/47/ds/08/x-thumbnail.jpeg'] }
      let(:solr_doc) do
        {
          'id' => pid,
          'thumbnail_path_ss' => 'path',
          'file_set_ids_ssim' => []
        }
      end

      it 'returns the error' do
        expect(service.verify).to eq({ derivatives: ['Index problem (fileset)'] })
      end
    end

    context 'when derivatives check fails due to error' do
      before do
        allow(service).to receive(:verify_file_set).and_raise(StandardError.new('I am an error'))
      end

      RSpec::Matchers.define :match_block do
        match do |response|
          response.call == { derivatives: ['I am an error'] }
        end
        supports_block_expectations
      end
      it 'raises error when hyrax fails' do
        expect { service.verify }.not_to raise_error
      end
      it 'returns the error message' do
        expect { service.verify }.to match_block
      end
    end
  end

  describe 'check_thumbnail' do
    context 'when it is an index problem' do
      let(:all_derivative_paths) { ['/data/tmp/shared/derivatives/c2/47/ds/08/x-jp2-0000.jp2', '/data/tmp/shared/derivatives/c2/47/ds/08/x-thumbnail.jpeg'] }
      let(:solr_doc) do
        {
          'id' => pid,
          'thumbnail_path_ss' => '',
          'file_set_ids_ssim' => []
        }
      end

      it 'returns a solr error' do
        service.instance_variable_set(:@verification_errors, { derivatives: [] })
        service.check_thumbnail(file_set)
        expect(service.verification_errors[:derivatives]).to include('Index problem (thumbnail)')
      end
    end

    context 'when it is a derivative problem' do
      let(:all_derivative_paths) { ['/data/tmp/shared/derivatives/c2/47/ds/08/x-jp2-0000.jp2'] }
      let(:solr_doc) do
        {
          'id' => pid,
          'thumbnail_path_ss' => '',
          'file_set_ids_ssim' => []
        }
      end

      it 'returns a derivative error' do
        service.instance_variable_set(:@verification_errors, { derivatives: [] })
        service.check_thumbnail(file_set)
        expect(service.verification_errors[:derivatives]).to include('Missing thumbnail')
      end
    end
  end

  describe 'check_pdf_derivatives' do
    context 'when the derivative is present' do
      let(:all_derivative_paths) { ['/data/tmp/shared/derivatives/c2/47/ds/08/x-jp2-0000.jp2', '/data/tmp/shared/derivatives/c2/47/ds/08/x-thumbnail.jpeg'] }

      it 'returns no errors' do
        service.instance_variable_set(:@verification_errors, { derivatives: [] })
        service.check_pdf_derivatives(file_set)
        expect(service.verification_errors).to eq({ derivatives: [] })
      end
    end

    context 'when the derivative is not present' do
      let(:all_derivative_paths) { [] }

      it 'returns the errors' do
        service.instance_variable_set(:@verification_errors, { derivatives: [] })
        service.check_pdf_derivatives(file_set)
        expect(service.verification_errors[:derivatives]).to include('Missing pages')
      end
    end
  end

  describe 'check_image_derivatives' do
    context 'when the derivative is present' do
      let(:all_derivative_paths) { ['/data/tmp/shared/derivatives/p8/41/8n/20/k-jp2.jp2', '/data/tmp/shared/derivatives/p8/41/8n/20/k-thumbnail.jpeg'] }

      it 'returns no errors' do
        service.instance_variable_set(:@verification_errors, { derivatives: [] })
        service.check_image_derivatives(file_set)
        expect(service.verification_errors).to eq({ derivatives: [] })
      end
    end

    context 'when the derivative is not present' do
      let(:all_derivative_paths) { [] }

      it 'returns the errors' do
        service.instance_variable_set(:@verification_errors, { derivatives: [] })
        service.check_image_derivatives(file_set)
        expect(service.verification_errors[:derivatives]).to include('Missing jp2 derivative')
      end
    end
  end

  describe 'check_office_document_derivatives' do
    context 'when the derivative is present' do
      let(:all_derivative_paths) { ['/data/tmp/shared/derivatives/nv/93/52/84/1-jp2-0000.jp2', '/data/tmp/shared/derivatives/nv/93/52/84/1-thumbnail.jpeg'] }

      it 'returns no errors' do
        service.instance_variable_set(:@verification_errors, { derivatives: [] })
        service.check_office_document_derivatives(file_set)
        expect(service.verification_errors).to eq({ derivatives: [] })
      end
    end

    context 'when the derivative is not present' do
      let(:all_derivative_paths) { [] }

      before { allow(file_set).to receive(:extracted_text).and_return nil }

      it 'returns the errors' do
        service.instance_variable_set(:@verification_errors, { derivatives: [] })
        service.check_office_document_derivatives(file_set)
        expect(service.verification_errors[:derivatives]).to include('Missing extracted text')
      end
    end
  end

  describe 'check_audio_derivatives' do
    context 'when derivative is present' do
      let(:all_derivative_paths) { ['/data/tmp/shared/derivatives/cn/69/m4/12/8-jp2.jp2', '/data/tmp/shared/derivatives/cn/69/m4/12/8-mp3.mp3', '/data/tmp/shared/derivatives/cn/69/m4/12/8-thumbnail.jpeg'] }

      it 'returns no errors' do
        service.instance_variable_set(:@verification_errors, { derivatives: [] })
        service.check_audio_derivatives(file_set)
        expect(service.verification_errors).to eq({ derivatives: [] })
      end
    end

    context 'when derivative is not present' do
      let(:all_derivative_paths) { [] }

      it 'returns the errors' do
        service.instance_variable_set(:@verification_errors, { derivatives: [] })
        service.check_audio_derivatives(file_set)
        expect(service.verification_errors[:derivatives]).to include('Missing mp3 derivative')
      end
    end
  end

  describe 'check_video_derivatives' do
    context 'when derivative is present' do
      let(:all_derivative_paths) { ['/data/tmp/shared/derivatives/nc/58/0m/64/9-jp2.jp2', '/data/tmp/shared/derivatives/nc/58/0m/64/9-mp4.mp4', '/data/tmp/shared/derivatives/nc/58/0m/64/9-thumbnail.jpeg'] }

      it 'returns no errors' do
        service.instance_variable_set(:@verification_errors, { derivatives: [] })
        service.check_video_derivatives(file_set)
        expect(service.verification_errors).to eq({ derivatives: [] })
      end
    end

    context 'when derivative is not present' do
      let(:all_derivative_paths) { [] }

      it 'returns the errors' do
        service.instance_variable_set(:@verification_errors, { derivatives: [] })
        service.check_video_derivatives(file_set)
        expect(service.verification_errors[:derivatives]).to include('Missing mp4 derivative')
      end
    end
  end
end
