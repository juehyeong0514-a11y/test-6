package com.aivle.bookapp.service;

import com.aivle.bookapp.domain.Book;
import com.aivle.bookapp.exception.BookNotFoundException;
import com.aivle.bookapp.repository.BookRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.util.Base64;
import java.util.List;
import java.util.UUID;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

@Service
@RequiredArgsConstructor
public class BookService {

    private static final Path COVER_UPLOAD_DIR = Path.of("/opt/bookapp/uploads/covers");
    private static final Pattern DATA_IMAGE_PATTERN = Pattern.compile("^data:image/(png|jpeg|jpg|webp);base64,(.+)$");

    private final BookRepository bookRepository;

    // 1. 도서 목록 전체 조회
    @Transactional(readOnly = true)
    public List<Book> findAllBooks() {
        return bookRepository.findAll(); // DB에 있는 모든 책을 가져옵니다.
    }

    // 2. 특정 도서 상세 조회
    @Transactional(readOnly = true)
    public Book findBookById(Long id) {
        // ID로 책을 찾고, 없으면 BookNotFoundException 발생.
        // 미션 6에서 GlobalExceptionHandler가 이 예외를 잡아 404 응답으로 변환할 예정.
        return bookRepository.findById(id)
                .orElseThrow(() -> new BookNotFoundException(id));
    }
    // 3. 신규 도서 등록
    @Transactional
    public Book createBook(Book book) {
        book.setCoverImageUrl(sanitizeCoverImageUrl(book.getCoverImageUrl()));
        return bookRepository.save(book); // DB에 새 책을 저장합니다.
    }

    // 4. 도서 정보 수정 (부분 수정 - PATCH)
    @Transactional
    public Book updateBook(Long id, Book patchBook) {
        // 먼저 기존 책이 있는지 찾습니다.
        Book existingBook = findBookById(id);

        // 프론트엔드에서 수정하라고 보낸(null이 아닌) 데이터만 골라서 업데이트합니다.
        if (patchBook.getTitle() != null) existingBook.setTitle(patchBook.getTitle());
        if (patchBook.getAuthor() != null) existingBook.setAuthor(patchBook.getAuthor());
        if (patchBook.getContent() != null) existingBook.setContent(patchBook.getContent());
        if (patchBook.getCategory() != null) existingBook.setCategory(patchBook.getCategory());
        if (patchBook.getCoverImageUrl() != null) {
            existingBook.setCoverImageUrl(sanitizeCoverImageUrl(patchBook.getCoverImageUrl()));
        }

        return bookRepository.save(existingBook);
    }

    // 5. 도서 삭제
    @Transactional
    public void deleteBook(Long id) {
        bookRepository.deleteById(id); // ID에 해당하는 책을 DB에서 삭제합니다.
    }

    // 6. 표지 URL 업데이트
    @Transactional
    public Book updateCover(Long id, String coverImageUrl) {
        Book existingBook = findBookById(id);

        existingBook.setCoverImageUrl(sanitizeCoverImageUrl(coverImageUrl));

        return bookRepository.save(existingBook);
    }

    private String sanitizeCoverImageUrl(String coverImageUrl) {
        if (coverImageUrl == null) {
            return null;
        }

        if (coverImageUrl.startsWith("data:image")) {
            return saveCoverImage(coverImageUrl);
        }

        return coverImageUrl;
    }

    private String saveCoverImage(String dataUrl) {
        Matcher matcher = DATA_IMAGE_PATTERN.matcher(dataUrl);
        if (!matcher.matches()) {
            return "";
        }

        String extension = normalizeExtension(matcher.group(1));
        byte[] imageBytes;
        try {
            imageBytes = Base64.getDecoder().decode(matcher.group(2));
        } catch (IllegalArgumentException ex) {
            return "";
        }

        String fileName = UUID.randomUUID() + "." + extension;
        Path target = COVER_UPLOAD_DIR.resolve(fileName);

        try {
            Files.createDirectories(COVER_UPLOAD_DIR);
            Files.write(target, imageBytes);
        } catch (IOException ex) {
            throw new IllegalStateException("Failed to save cover image", ex);
        }

        return "/uploads/covers/" + fileName;
    }

    private String normalizeExtension(String extension) {
        if ("jpeg".equals(extension)) {
            return "jpg";
        }
        return extension;
    }
}
