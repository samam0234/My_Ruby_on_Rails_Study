json.partial! "api/v1/posts/post", post: @post
json.comments @comments, partial: "api/v1/comments/comment", as: :comment
