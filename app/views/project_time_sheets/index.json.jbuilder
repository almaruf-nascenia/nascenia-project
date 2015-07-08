json.array!(@project_time_sheets) do |project_time_sheet|
  json.extract! project_time_sheet, :id, :Title, :Description, :Link
  json.url project_time_sheet_url(project_time_sheet, format: :json)
end
