package todoApp.common

is_member_of(user, group) := x {
  x := ds.check_relation({
    "object": {
      "key": group,
      "type": "group"
    },
    "relation": {
      "name": "member",
      "object_type": "group"
    },
    "subject": {
      "key": user.key,
      "type": "user"
    }
  })
}

check(user, permission, todo) := x {
  x := ds.check_permission({
    "object": {
      "key": todo,
      "type": "todo"
    },
    "permission": {
      "name": permission,
    },
    "subject": {
      "key": user.key,
      "type": "user"
    }
  })
}
