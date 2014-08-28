 @!macro [new] thread_safe_immutable_object

   @note This is an immutable, read-only, frozen, thread safe object that can
     be used in concurrent systems. Thread safety guarantees *cannot* be made
     about objects contained *within* this object, however. Ruby variables are
     mutable references to mutable objects. This cannot be changed. The best
     practice it to only encapsulate immutable, frozen, or thread safe objects.
     Ultimately, thread safety is the responsibility of the programmer.

 @!macro [new] thread_safe_final_object

   @note This is a write-once, read-many, thread safe object that can
     be used in concurrent systems. Thread safety guarantees *cannot* be made
     about objects contained *within* this object, however. Ruby variables are
     mutable references to mutable objects. This cannot be changed. The best
     practice it to only encapsulate immutable, frozen, or thread safe objects.
     Ultimately, thread safety is the responsibility of the programmer.
